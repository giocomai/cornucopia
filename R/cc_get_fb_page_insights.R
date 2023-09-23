#' Get Facebook page insights
#'
#' Official documentation: \url{https://developers.facebook.com/docs/graph-api/reference/v18.0/insights}
#'
#' @param metric
#' @param fb_page_id
#' @param fb_page_token
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_page_insights <- function(metric = c(
                                      "page_impressions"
                                    ),
                                    start_date = NULL,
                                    end_date = NULL,
                                    api_version = "v18.0",
                                    cache = TRUE,
                                    fb_page_id = NULL,
                                    fb_page_token = NULL) {
  if (is.null(fb_page_token)) {
    fb_page_token <- cc_get_settings(fb_page_token = fb_page_token) |>
      purrr::pluck("fb_page_token")
  } else {
    fb_page_token <- as.character(fb_page_token)
  }

  if (is.null(fb_page_id)) {
    fb_page_id <- cc_get_settings(fb_page_id = fb_page_id) |>
      purrr::pluck("fb_page_id")
  } else {
    fb_page_id <- as.character(fb_page_id)
  }

  if (is.null(start_date)) {
    start_date <- cc_get_settings(start_date = start_date) |>
      purrr::pluck("start_date")
  } else {
    start_date <- as.character(start_date)
  }

  if (is.null(end_date)) {
    end_date <- cc_get_settings(end_date = end_date) |>
      purrr::pluck("end_date")
  } else {
    end_date <- as.character(end_date)
  }

  all_dates_v <- seq.Date(
    from = lubridate::as_date(start_date),
    to = lubridate::as_date(end_date),
    by = "day"
  )

  dates_to_process_v <- all_dates_v

  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
    }
    fs::dir_create("cornucopia_db")

    db <- DBI::dbConnect(
      drv = RSQLite::SQLite(),
      fs::path(
        "cornucopia_db",
        fs::path_ext_set(stringr::str_c("fb_page_", fb_page_id), ".sqlite") |>
          fs::path_sanitize()
      )
    )

    current_table <- "fb_page_insights"

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = tibble::as_tibble(cc_empty_fb_page_insights)
      )
    }

    active_metrics <- metric
    
    previous_fb_page_insights_df <- DBI::dbReadTable(
      conn = db,
      name = current_table
    ) |>
      dplyr::filter(
        metric %in% active_metrics,
        date %in% all_dates_v
      ) |>
      dplyr::collect() |>
      tibble::as_tibble()

    if (nrow(previous_fb_page_insights_df) > 0) {
      dates_to_process_v <- all_dates_v[!(all_dates_v %in% previous_fb_page_insights_df[["date"]])]

      if (length(dates_to_process_v) == 0) {
        DBI::dbDisconnect(db)
        return(previous_fb_page_insights_df |>
          dplyr::arrange(date, metric))
      }
    }
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  dates_to_process_v

  new_df <- purrr::map(
    .x = dates_to_process_v,
    .progress = TRUE,
    .f = function(current_date) {
      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(fb_page_id) |>
        httr2::req_url_path_append("insights") |>
        httr2::req_url_path_append(stringr::str_flatten(string = metric, collapse = ",")) |>
        httr2::req_url_path_append("day") |>
        httr2::req_url_query(
          access_token = fb_page_token,
          since = current_date,
          until = current_date
        )

      req <- httr2::req_perform(req = api_request)

      page_insight_l <- httr2::resp_body_json(req)

      current_date_df <- purrr::map(
        .x = page_insight_l[["data"]],
        .f = function(current_element_l) {
          purrr::map(.x = current_element_l |>
            purrr::pluck("values"), .f = function(current_values_l) {
            current_values_l |>
              tibble::as_tibble()
          }) |>
            purrr::list_rbind() |>
            dplyr::mutate(
              metric = current_element_l[["name"]],
              metric_title = current_element_l[["title"]],
              period = current_element_l[["period"]]
            ) |>
            dplyr::relocate(metric, metric_title, period, value, end_time)
        }
      ) |>
        purrr::list_rbind()

      out_df <- current_date_df |>
        dplyr::mutate(
          value = as.numeric(value),
          date = (lubridate::as_datetime(
            x = end_time,
            tz = "UTC",
            format = "%Y-%m-%dT%H:%M:%S%z"
          ) |>
            lubridate::as_date() |>
            as.character())
        ) |>
        dplyr::relocate(date)

      if (cache == TRUE) {
        DBI::dbAppendTable(
          conn = db,
          name = current_table,
          value = out_df
        )
      }

      out_df
    }
  ) |>
    purrr::list_rbind()


  if (cache == TRUE) {
    output_df <- dplyr::bind_rows(
      previous_fb_page_insights_df,
      new_df
    ) |>
      tibble::as_tibble() |>
      dplyr::distinct() |>
      dplyr::arrange(date, metric)

    DBI::dbDisconnect(db)
  } else {
    output_df <- new_df
  }

  output_df
}
