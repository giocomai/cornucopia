#' Get Facebook ad creatives id for each ad id
#'
#' See: https://developers.facebook.com/docs/marketing-api/reference/adgroup/adcreatives/
#'
#'
#' @return A data frame with three character columns: `ad_id`, `creative_id`, and `timestamp_retrieved`
#' @export
#'
#' @examples
cc_get_fb_ad_creatives_id <- function(ad_id = NULL,
                                      ad_account_id = NULL,
                                      api_version = "v17.0",
                                      cache = TRUE,
                                      token = NULL) {
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
        fs::path_ext_set(stringr::str_c("fb_", fb_ad_account_id), ".sqlite") |>
          fs::path_sanitize()
      )
    )

    current_table <- "fb_ad_creatives_id"

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = cc_empty_fb_ad_creatives_id
      )
    }

    ad_id_all_requested_v <- ad_id

    previous_ad_creatives_df <- DBI::dbReadTable(
      conn = db,
      name = current_table
    ) |>
      dplyr::filter(ad_id %in% ad_id_all_requested_v) |>
      dplyr::collect() |>
      tibble::as_tibble()

    if (nrow(previous_ad_creatives_df) > 0) {
      previous_ad_creatives_df <- previous_ad_creatives_df |>
        dplyr::distinct()

      previous_ad_id_v <- previous_ad_creatives_df |>
        dplyr::pull(ad_id)
    } else {
      previous_ad_id_v <- character()
    }
  } else {
    previous_ad_id_v <- character()
  }

  ad_id_to_process_v <- ad_id[!(ad_id %in% previous_ad_id_v)]


  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )


  ad_creatives_df <- purrr::map(
    .x = ad_id_to_process_v,
    .progress = "Retrieving ad creatives id",
    .f = function(current_ad_id) {
      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(current_ad_id) |>
        httr2::req_url_path_append("adcreatives") |>
        httr2::req_url_query(
          access_token = fb_user_token
        )

      req <- httr2::req_perform(req = api_request)

      ad_creative_l <- httr2::resp_body_json(req)

      current_ad_creatives_df <- purrr::map(
        .x = ad_creative_l[["data"]],
        .f = function(current_ad_creative) {
          tibble::tibble(creative_id = current_ad_creative |> purrr::pluck("id"))
        }
      ) |>
        purrr::list_rbind() |>
        dplyr::mutate(ad_id = current_ad_id) |>
        dplyr::relocate(ad_id) |>
        dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z"))

      if (cache == TRUE) {
        DBI::dbAppendTable(
          conn = db,
          name = current_table,
          value = current_ad_creatives_df
        )
      }

      current_ad_creatives_df
    }
  ) |>
    purrr::list_rbind()


  if (cache == TRUE) {
    output_df <- dplyr::bind_rows(
      previous_ad_creatives_df,
      ad_creatives_df
    ) |>
      tibble::as_tibble() |>
      dplyr::distinct()

    DBI::dbDisconnect(db)
  } else {
    output_df <- ad_creatives_df
  }

  output_df
}
