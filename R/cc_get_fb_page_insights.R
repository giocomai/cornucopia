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
                                      "page_impressions",
                                      "page_engaged_users"
                                    ),
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


  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_page_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_path_append(stringr::str_flatten(string = metric, collapse = ",")) |>
    httr2::req_url_path_append("day") |>
    httr2::req_url_query(access_token = fb_page_token)

  req <- httr2::req_perform(req = api_request)

  page_insight_l <- httr2::resp_body_json(req)

  purrr::map(
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
}
