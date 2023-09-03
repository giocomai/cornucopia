#' Takes all action results for all days when an ad is active
#'
#' Draft: no caching and returns only 25 days for each ad, as paging in data retrieval has not been enabled
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_ad_actions_by_day <- function(ad_id = NULL,
                                        type = "actions",
                                        cache = TRUE,
                                        only_cached = FALSE,
                                        api_version = "v17.0",
                                        ad_account_id = NULL,
                                        token = NULL) {
  if (!(type %in% c("actions", "action_values", "cost_per_action_type"))) {
    cli::cli_abort("Invalid type. Check documentation.")
  }

  if (is.null(ad_id)) {
    ads_df <- cc_get_fb_ads()
    ad_id <- ads_df |>
      dplyr::distinct(ad_id) |>
      dplyr::pull(ad_id)
  }

  if (is.null(token)) {
    fb_user_token <- cc_get_settings(fb_user_token = token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(token)
  }

  if (is.null(ad_account_id)) {
    fb_ad_account_id <- cc_get_settings(fb_ad_account_id = ad_account_id) |>
      purrr::pluck("fb_ad_account_id")
  } else {
    fb_ad_account_id <- as.character(ad_account_id)
  }


  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
    }
    fs::dir_create("cornucopia_db")

    db <- DBI::dbConnect(
      drv = RSQLite::SQLite(),
      fs::path(
        "cornucopia_db",
        fs::path_ext_set(stringr::str_c("fb_ad_", fb_ad_account_id), ".sqlite") |>
          fs::path_sanitize()
      )
    )

    current_table <- stringr::str_c("fb_ad_", type)

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = cc_empty_fb_ad_actions
      )
    }

    previous_fb_ad_details_df <- DBI::dbReadTable(
      conn = db,
      name = current_table
    ) |>
      dplyr::collect() |>
      tibble::as_tibble()

    # TODO
    # first check how long an ad has run, and then see if all dates are cached
    # if not, retrieve further
    tibble::tibble(ad_id = ad_id)

    previous_fb_ad_details_df |>
      dplyr::distinct(ad_id, date)

    ad_id_to_process_v <- ad_id[!(ad_id %in% unique(previous_fb_ad_details_df$ad_id))]
  } else {
    ad_id_to_process_v <- ad_id
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  new_fb_ad_details_df <- purrr::map(
    .x = ad_id_to_process_v,
    .progress = stringr::str_c("Retrieving ad details"),
    .f = function(current_ad_id) {
      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(current_ad_id) |>
        httr2::req_url_path_append("insights") |>
        httr2::req_url_query(
          fields = type,
          access_token = fb_user_token,
          date_preset = "maximum",
          time_increment = 1
        )

      req <- httr2::req_perform(req = api_request)

      response_l <- httr2::resp_body_json(req) |>
        purrr::pluck("data")

      purrr::map(
        .x = response_l,
        .f = function(response_for_current_date) {
          purrr::map(.x = response_for_current_date[[type]], .f = function(x) {
            x |> tibble::as_tibble()
          }) |>
            purrr::list_rbind() |>
            dplyr::mutate(date = response_for_current_date[["date_start"]]) |>
            dplyr::relocate(date)
        }
      ) |>
        purrr::list_rbind() |>
        dplyr::mutate(ad_id = current_ad_id) |>
        dplyr::relocate(ad_id)
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(value = as.numeric(value))



  if (cache == TRUE) {
    output_df <- dplyr::bind_rows(
      previous_fb_ad_details_df,
      new_fb_ad_details_df
    ) |>
      tibble::as_tibble() |>
      dplyr::distinct(ad_id, date, action_type, .keep_all = TRUE)

    DBI::dbDisconnect(db)
  } else {
    output_df <- new_fb_ad_details_df
  }

  output_df
}
