#' Get custom stats about an ad (currently not functional)
#'
#' https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-stats/
#'
#' attribution window
#' https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/
#'
#'
#' @return
#'
#' @examples
cc_get_fb_ad_custom <- function(
  fields = "reach",
  breakdowns = "frequency_value",
  ad_id = NULL,
  start_date = NULL,
  end_date = NULL,
  only_cached = FALSE,
  api_version = "v24.0",
  cache = TRUE,
  ad_account_id = NULL,
  fb_user_token = NULL
) {
  dates_l <- cc_get_settings(
    start_date = start_date,
    end_date = end_date
  )

  start_date <- dates_l$start_date
  end_date <- dates_l$end_date

  dates <- as.Date(start_date:end_date, origin = as.Date("1970-01-01"))

  names(dates) <- dates

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

  cc_date_to_json(start_date = dates)

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(current_ad_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      fields = "action_values", # cost_per_action_type # action_values #actions # conversion_rate_ranking #cpc # frequency # reach # purchase_roas
      # fields = "platform_position",
      # breakdowns = "product_id",
      access_token = fb_user_token,
      # time_range = cc_date_to_json(start_date = dates),
      date_preset = "maximum",
      # action_attribution_windows="1d_click,1d_ev,1d_view,7d_click,7d_view,28d_click, 28d_view",
      # time_increment = 1
      #  summary = "true"
    )

  api_request <- httr2::request(base_url = base_url) |>
    # httr2::req_url_path_append(stringr::str_c("act_", fb_ad_account_id)) |>
    # httr2::req_url_path_append("ads") |>
    httr2::req_url_path_append(current_ad_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      fields = fields,
      breakdowns = breakdowns,
      # time_increment = 1,
      access_token = fb_user_token,
      date_preset = "maximum",
      #  summary = "true"
    )

  # list
  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(stringr::str_c("act_", fb_ad_account_id)) |>
    httr2::req_url_path_append("ads") |>
    httr2::req_url_query(
      fields = "id,name,tracking_specs",
      # fields = "actions",
      # breakdowns = "product_id",
      # time_increment = 1,
      access_token = fb_user_token,
      date_preset = "maximum"
      #  summary = "true"
    )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(current_ad_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      fields = fields,
      breakdowns = breakdowns,
      # time_increment = 1,
      access_token = fb_user_token,
      #date_preset = "maximum",
      #  summary = "true"
    )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(current_ad_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      fields = "impressions",
      # breakdowns = "hourly_stats_aggregated_by_audience_time_zone",
      # time_increment = 1,
      access_token = fb_user_token,
      #date_preset = "maximum",
      # summary = "true"
      date_preset = "last_7d"
    )

  httr2::req_dry_run(req = api_request)
  req <- httr2::req_perform(req = api_request)

  response_l <- httr2::resp_body_json(req)
  response_l
  response_l$data
}
