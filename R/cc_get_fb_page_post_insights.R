#' Get Facebook page posts insights
#'
#' For reference, see: https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts
#' defaults to Lifetime period for each post.
#'
#' Cache not yet working.
#'
#' @inheritParams cc_api_get_fb_page_post_insights
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_page_post_insights <- function(
  fb_post_id = NULL,
  metric = cc_valid_fields_fb_post_insights,
  period = "lifetime",
  cache = TRUE,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
) {
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

  if (is.null(fb_post_id)) {
    cc_get_fb_page_posts(
      meta_api_version = meta_api_version,
      max_pages = NULL,
      fields = names(cc_empty_fb_page_post_df),
      cache = cache,
      fb_page_id = fb_page_id,
      fb_page_token = fb_page_token
    ) |>
      dplyr::pull(id)
  }

  purrr::map(
    .x = fb_post_id,
    .progress = TRUE,
    .f = function(x) {
      cc_api_get_fb_page_post_insights(
        fb_post_id = x,
        metric = metric,
        period = period,
        cache = cache,
        update = update,
        meta_api_version = meta_api_version,
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
#' @param metric Metrics to be retrieved. Consider that depending on the media
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
cc_api_get_fb_page_post_insights <- function(
  fb_post_id,
  metric = cc_valid_fields_fb_post_insights,
  period = "lifetime",
  cache = TRUE,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
) {
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
    meta_api_version
  )

  metrics_v <- stringr::str_c(metric, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_post_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      metric = metrics_v,
      period = period,
      access_token = fb_page_token
    )

  response_l <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (!is.null(response_l[["error"]][["message"]])) {
    cli::cli_alert_warning(response_l[["error"]][["message"]])
    return(NULL)
  }

  output_df <- purrr::map(
    .x = response_l[["data"]],
    .f = function(current_element_l) {
      purrr::map(
        .x = current_element_l[["values"]],
        .f = function(current_values_l) {
          current_metric_value_names <- current_element_l |>
            purrr::pluck("values", 1, "value") |>
            names()

          if (length(current_metric_value_names) == 0) {
            current_metric_value_names <- NA_character_
          }

          current_metric_value <- current_element_l |>
            purrr::pluck("values", 1, "value") |>
            as.numeric()

          if (length(current_metric_value) == 0) {
            current_metric_value <- as.numeric(0)
          }

          metric_name <- current_element_l |> purrr::pluck("name")

          metric_title <- current_element_l |> purrr::pluck("title")

          if (length(metric_title) == 0) {
            metric_title <- metric_name
          }

          metric_description <- current_element_l |> purrr::pluck("description")

          if (length(metric_description) == 0) {
            metric_description <- metric_name
          }

          tibble::tibble(
            metric_title = metric_title,
            metric_description = metric_description,
            metric_name = current_element_l |> purrr::pluck("name"),
            metric_value_name = current_metric_value_names,
            metric_value = current_metric_value
          )
        }
      ) |>
        purrr::list_rbind() |>
        dplyr::mutate(
          fb_post_id = as.character(fb_post_id),
          period = current_element_l[["period"]]
        ) |>
        dplyr::relocate(
          fb_post_id,
          metric_title,
          metric_description,
          metric_name,
          metric_value_name,
          metric_value,
          period
        ) |>
        dplyr::mutate(
          timestamp_retrieved = strftime(
            as.POSIXlt(Sys.time(), "UTC"),
            "%Y-%m-%dT%H:%M:%S%z"
          )
        )
    }
  ) |>
    purrr::list_rbind()

  output_df
}
