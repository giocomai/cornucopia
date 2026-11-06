#' Get ad attribution
#'
#' For details, see the
#' \href{https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/}{official
#' documentation on Ads Action Stats}.
#'
#'
#' @param ad_id Indentifier of a an `ad_id`, `adset_id`, or `campaign_id`.
#' @param date_preset Defaults to "maximum". Available values include "last_7d",
#'   "last_30d", and similar, as described in the
#'   \href{https://developers.facebook.com/docs/marketing-api/insights/breakdowns}{official
#'   API documentation}. N.B. This is ignored if both `start_date` and
#'   `end_date` are given.
#' @param start_date The beginning date for the period to be considered. Both
#'   `start_date` and `end_date` must be given. If either is ignored, `preset`
#'   takes precedence.
#' @param end_date The end date for the period to be considered. Both
#'   `start_date` and `end_date` must be given. If either is ignored, `preset`
#'   takes precedence.
#' @param output Output format, defaults to `tibble`. Valid values include
#'   `list` and `barchart`, which outputs a `ggplot2` object.
#' @return
#' @export
#'
#' @examples
cc_get_fb_ad_attribution <- function(
  ad_id = NULL,
  fields = c(
    "campaign_name",
    "campaign_id",
    "adset_name",
    "adset_id",
    "ad_name",
    "ad_id",
    "actions",
    "action_values"
  ),
  action_attribution_windows = c(
    "1d_view",
    "7d_view",
    "28d_view",
    "1d_click",
    "7d_click",
    "28d_click",
    "incrementality"
  ),
  date_preset = c(
    "maximum",
    "last_7d",
    "last_30d",
    "today",
    "yesterday",
    "this_month",
    "last_month",
    "this_quarter",
    "maximum",
    "data_maximum",
    "last_3d",
    "last_7d",
    "last_14d",
    "last_28d",
    "last_30d",
    "last_90d",
    "last_week_mon_sun",
    "last_week_sun_sat",
    "last_quarter",
    "last_year",
    "this_week_mon_today",
    "this_week_sun_today",
    "this_year"
  ),
  output = c("tibble", "list"),
  start_date = NULL,
  end_date = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ad_account_id = NULL,
  fb_user_token = NULL
) {
  if (!is.null(start_date) & !is.null(end_date)) {
    dates_l <- cc_get_settings(
      start_date = start_date,
      end_date = end_date
    )
    time_range <- cc_date_to_json(
      start_date = dates_l$start_date,
      end_date = dates_l$end_date
    )
  }

  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  if (is.null(ad_account_id)) {
    fb_ad_account_id <- cc_get_settings(fb_ad_account_id = ad_account_id) |>
      purrr::pluck("fb_ad_account_id")
  } else {
    fb_ad_account_id <- as.character(ad_account_id)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    meta_api_version
  )

  fields_param <- paste(fields, collapse = ",")
  attribution_param <- jsonlite::toJSON(action_attribution_windows)

  if (!is.null(start_date) & !is.null(end_date)) {
    api_request <- httr2::request(base_url = base_url) |>
      httr2::req_url_path_append(ad_id) |>
      httr2::req_url_path_append("insights") |>
      httr2::req_url_query(
        fields = fields_param,
        action_attribution_windows = attribution_param,
        time_range = time_range,
        access_token = fb_user_token
      )
  } else {
    api_request <- httr2::request(base_url = base_url) |>
      httr2::req_url_path_append(ad_id) |>
      httr2::req_url_path_append("insights") |>
      httr2::req_url_query(
        fields = fields_param,
        action_attribution_windows = attribution_param,
        access_token = fb_user_token,
        date_preset = date_preset[[1]]
      )
  }

  req <- httr2::req_perform(req = api_request)

  response_l <- httr2::resp_body_json(req)

  if (output[[1]] == "list") {
    return(response_l[["data"]])
  }

  response_df <- purrr::map(
    .x = response_l[["data"]],
    .f = \(ad_row) {
      base_info <- purrr::keep(ad_row, ~ !is.list(.x)) |>
        as_tibble()

      unpack_action_list <- function(action_list, metric_name) {
        if (is.null(action_list) || length(action_list) == 0) {
          return(tibble::tibble())
        }

        purrr::map(action_list, ~ tibble::as_tibble(.x)) |>
          purrr::list_rbind() |>
          tidyr::pivot_longer(
            cols = -action_type,
            names_to = "attribution_window",
            values_to = metric_name,
            values_drop_na = TRUE
          ) |>
          mutate(!!metric_name := as.numeric(.data[[metric_name]]))
      }

      df_actions <- unpack_action_list(
        ad_row[["actions"]],
        metric_name = "action_count"
      )
      df_values <- unpack_action_list(
        ad_row[["action_values"]],
        metric_name = "action_value"
      )

      df_combined <- dplyr::full_join(
        df_actions,
        df_values,
        by = c("action_type", "attribution_window")
      )

      if (nrow(df_combined) > 0) {
        bind_cols(base_info, df_combined)
      } else {
        base_info
      }
    }
  ) |>
    purrr::list_rbind()

  response_df
}
