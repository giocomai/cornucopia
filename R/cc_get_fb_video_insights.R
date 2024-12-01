#' Get Facebook video insights
#'
#' For reference, see: https://developers.facebook.com/docs/graph-api/reference/video/video_insights/
#' defaults to Lifetime period for each video
#'
#' @param fb_video_id
#' @param metrics
#' @param cache
#' @param update
#' @param api_version
#' @param fb_page_id
#' @param fb_page_token
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_video_insights <- function(fb_video_id,
                                     metrics = cc_valid_fields_fb_video_insights,
                                     cache = TRUE,
                                     update = TRUE,
                                     api_version = "v21.0",
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

  purrr::map(
    .x = fb_video_id,
    .progress = TRUE,
    .f = function(x) {
      cc_api_get_fb_video_insights(
        fb_video_id = x,
        metrics = metrics,
        cache = cache,
        update = update,
        api_version = api_version,
        fb_page_id = fb_page_id,
        fb_page_token = fb_page_token
      )
    }
  ) |>
    purrr::list_rbind()
}



#' Get information about a single Facebook video directly from the API. Mostly used
#' internally.
#'
#' See the official documentation for reference:
#' \url{https://developers.facebook.com/docs/graph-api/reference/video/video_insights/}
#'
#' @param fb_video_id Instagram media identifier, must be a vector of length 1.
#'   A list of identifiers for your account can be retrieved with
#'   `cc_get_fb_page_video()`.
#' @param metrics Metrics to be retrieved. Consider that depending on the media
#'   type, different media types are effectively available. Requesting the wrong
#'   metrics will cause an error. Defaults to NULL. If left to NULL, metrics will be chosen based on the media type. See the official documentation for reference:
#'   \url{ https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts}
#'
#' @inheritParams cc_get_fb_page_video
#'
#' @return
#' @export
#'
#' @examples
cc_api_get_fb_video_insights <- function(fb_video_id,
                                         metrics = cc_valid_fields_fb_video_insights,
                                         cache = TRUE,
                                         update = TRUE,
                                         api_version = "v21.0",
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


  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  metrics_v <- stringr::str_c(metrics, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_video_id) |>
    httr2::req_url_path_append("video_insights") |>
    httr2::req_url_query(
      metric = metrics_v,
      period = "lifetime",
      access_token = fb_page_token
    )

  req <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  current_l <- httr2::resp_body_json(req)

  if (is.null(current_l[["error"]][["message"]]) == FALSE) {
    cli::cli_warn(current_l[["error"]][["message"]])
    return(invisible(NULL))
  }

  output_df <- purrr::map(
    .x = current_l[["data"]],
    .f = function(x) {
      tibble::tibble(
        metric_title = x |> purrr::pluck("title"),
        metric_name = x |> purrr::pluck("name"),
        metric_value_name = x |> purrr::pluck("values", 1, "value") |> names(),
        metric_value = x |> purrr::pluck("values", 1, "value") |> as.numeric()
      )
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(fb_video_id = fb_video_id) |>
    dplyr::relocate(fb_video_id) |>
    dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z"))

  output_df
}
