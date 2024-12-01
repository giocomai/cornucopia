#' Takes all action results for all days when an ad is active
#'
#' For action breakdowns, see: https://developers.facebook.com/docs/marketing-api/insights/breakdowns/
#'
#' Draft: caching disabled by default as only partly functional;
#' Not yet fully tested with ads running longer than 25 days
#'
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_ad_actions_by_day <- function(ad_id = NULL,
                                        type = "actions",
                                        action_breakdowns = NULL,
                                        cache = FALSE,
                                        only_cached = FALSE,
                                        api_version = "v21.0",
                                        ad_account_id = NULL,
                                        token = NULL,
                                        max_pages = NULL) {
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

  all_new_fb_ad_details_df <- purrr::map(
    .x = ad_id_to_process_v,
    .progress = stringr::str_c("Retrieving ad details"),
    .f = function(current_ad_id) {
      out <- vector("list", max_pages %||% 1000)
      ad_details_l <- vector("list", max_pages %||% 1000)

      i <- 1L

      # cli::cli_progress_bar(name = stringr::str_c("Retrieving Facebook ad actions for ad ",
      #                                             sQuote(current_ad_id),
      #                                             ":"))

      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(current_ad_id) |>
        httr2::req_url_path_append("insights") |>
        httr2::req_url_query(
          fields = type,
          action_breakdowns = action_breakdowns,
          access_token = fb_user_token,
          date_preset = "maximum",
          time_increment = 1
        )

      repeat({
        # cli::cli_progress_update(inc = 25)

        out[[i]] <- httr2::req_perform(api_request) |>
          httr2::resp_body_json()

        if (!is.null(max_pages) && i == max_pages) {
          break
        }

        req <- httr2::req_perform(req = api_request)

        response_l <- httr2::resp_body_json(req) |>
          purrr::pluck("data")


        new_fb_ad_details_pre_df <- purrr::map(
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


        if (ncol(new_fb_ad_details_pre_df) < 4) {
          new_fb_ad_details_df <- cc_empty_fb_ad_actions
        } else {
          new_fb_ad_details_df <- new_fb_ad_details_pre_df |>
            dplyr::mutate(value = as.numeric(value))
        }

        ad_details_l[[i]] <- new_fb_ad_details_df

        if (nrow(new_fb_ad_details_df) == 0) {
          # do nothing
        } else {
          if (cache == TRUE) {
            DBI::dbAppendTable(
              conn = db,
              name = current_table,
              value = new_fb_ad_details_df
            )
          }
        }

        if (purrr::pluck_exists(out[[i]], "paging", "next") == TRUE) {
          api_request <- purrr::pluck(out[[i]], "paging", "next") |>
            httr2::request()
        } else {
          break
        }

        i <- i + 1L
        if (i > length(out)) {
          length(out) <- length(out) * 2L
        }
      })

      # cli::cli_process_done()

      current_ad_details_df <- ad_details_l |>
        purrr::list_rbind() |>
        tibble::as_tibble()

      current_ad_details_df
    }
  ) |>
    purrr::list_rbind()


  if (cache == TRUE) {
    output_df <- dplyr::bind_rows(
      all_new_fb_ad_details_df,
      previous_fb_ad_details_df
    ) |>
      tibble::as_tibble() |>
      dplyr::distinct()

    DBI::dbDisconnect(db)
  } else {
    output_df <- all_new_fb_ad_details_df
  }

  output_df |>
    dplyr::distinct()
}
