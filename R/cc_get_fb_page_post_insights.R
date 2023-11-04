#' Get Facebook page posts insights
#'
#' For reference, see: https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts
#' defaults to Lifetime period for each post.
#'
#' @param fb_post_id
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
cc_get_fb_page_post_insights <- function(fb_post_id,
                                         metrics = cc_valid_fields_fb_post_insights,
                                         cache = TRUE,
                                         update = TRUE,
                                         api_version = "v18.0",
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
    .x = fb_post_id,
    .progress = TRUE,
    .f = function(x) {
      cc_api_get_fb_page_post_insights(
        fb_post_id = x,
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



#' Get information about a single media directly from the API. Mostly used
#' internally.
#'
#' See the official documentation for reference:
#' \url{ https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts}
#'
#' @param fb_post_id Instagram media identifier, must be a vector of length 1.
#'   A list of identifiers for your account can be retrieved with
#'   `cc_get_fb_page_posts()`.
#' @param metrics Metrics to be retrieved. Consider that depending on the media
#'   type, different media types are effectively available. Requesting the wrong
#'   metrics will cause an error. Defaults to NULL. If left to NULL, metrics will be chosen based on the media type. See the official documentation for reference:
#'   \url{ https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts}
#'
#' @inheritParams cc_get_fb_page_posts
#'
#' @return
#' @export
#'
#' @examples
cc_api_get_fb_page_post_insights <- function(fb_post_id,
                                             metrics = cc_valid_fields_fb_post_insights,
                                             cache = TRUE,
                                             update = TRUE,
                                             api_version = "v18.0",
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
    httr2::req_url_path_append(fb_post_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      metric = metrics_v,
      period = "lifetime",
      access_token = fb_page_token
    )

  req <- httr2::req_perform(req = api_request)

  current_l <- httr2::resp_body_json(req)

  output_df <- purrr::map(
    .x = current_l[["data"]],
    .f = function(x) {
      tibble::tibble(
        metric_title = x |> purrr::pluck("title"),
        metric_name = x |> purrr::pluck("name"),
        metric_value = x |> purrr::pluck("values", 1, "value") |> as.numeric()
      )
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(fb_post_id = fb_post_id) |>
    dplyr::relocate(fb_post_id) |>
    dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z"))

  output_df
}
