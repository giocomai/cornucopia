#' Get frequency distribution
#'
#' https://developers.facebook.com/docs/marketing-api/insights/breakdowns
#'
#' Warning: custom time ranges not yet functional
#'
#' @param ad_id Indentifier of a an ad_id, adset_id, or campaign_id.
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_ad_frequency_distribution <- function(
  ad_id = NULL,
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
  output = c("tibble", "barchart", "list"),
  start_date = NULL,
  end_date = NULL,
  api_version = "v23.0",
  ad_account_id = NULL,
  fb_user_token = NULL
) {
  if (is.null(date_preset)) {
    dates_l <- cc_get_settings(
      start_date = start_date,
      end_date = end_date
    )

    start_date <- dates_l$start_date
    end_date <- dates_l$end_date

    dates <- as.Date(start_date:end_date, origin = as.Date("1970-01-01"))

    names(dates) <- dates

    date_preset <- dates

    cc_date_to_json(start_date = dates)
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
    api_version
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(ad_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      fields = "reach",
      breakdowns = "frequency_value",
      access_token = fb_user_token,
      date_preset = date_preset[[1]]
    )

  req <- httr2::req_perform(req = api_request)

  response_l <- httr2::resp_body_json(req)

  if (output[[1]] == "list") {
    return(response_l[["data"]])
  }
  frequency_distribution_df <- purrr::map(
    .x = response_l[["data"]],
    .f = \(current_response) {
      current_response |>
        tibble::as_tibble()
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(
      first_figure = stringr::str_extract(
        string = frequency_value,
        pattern = "[[:digit:]]+"
      ) |>
        as.integer()
    ) |>
    dplyr::arrange(first_figure) |>
    dplyr::mutate(frequency_value = forcats::fct_inorder(frequency_value)) |>
    dplyr::select(-first_figure) |>
    dplyr::mutate(
      reach = as.numeric(reach),
      date_start = as.Date(date_start),
      date_stop = as.Date(date_stop)
    ) |>
    dplyr::mutate(share = reach / sum(reach))

  if (output[[1]] == "tibble") {
    return(frequency_distribution_df)
  }

  ratio <- max(frequency_distribution_df$reach) /
    max(frequency_distribution_df$share)

  ads_df <- cc_get_fb_ads()

  if (ad_id %in% ads_df$campaign_id) {
    title_string <- ads_df |>
      dplyr::filter(campaign_id == !!ad_id) |>
      dplyr::slice_max(date, n = 1, with_ties = FALSE) |>
      dplyr::pull(campaign_name)
  } else if (ad_id %in% ads_df$adset_id) {
    title_string <- ads_df |>
      dplyr::filter(adset_id == !!ad_id) |>
      dplyr::slice_max(date, n = 1, with_ties = FALSE) |>
      dplyr::pull(adset_name)
  } else {
    title_string <- ads_df |>
      dplyr::filter(ad_id == !!ad_id) |>
      dplyr::slice_max(date, n = 1, with_ties = FALSE) |>
      dplyr::pull(ad_name)
  }

  frequency_distribution_df |>
    ggplot2::ggplot(mapping = ggplot2::aes(x = frequency_value, y = reach)) +
    ggplot2::geom_col() +
    ggplot2::scale_y_continuous(
      name = "Reach",
      labels = scales::number,
      sec.axis = ggplot2::sec_axis(
        ~ . / ratio,
        labels = scales::label_percent()
      )
    ) +
    ggplot2::scale_x_discrete(name = "Frequency distribution") +
    ggplot2::labs(
      title = title_string,
      subtitle = stringr::str_flatten(
        string = c(
          "Between ",
          frequency_distribution_df |>
            dplyr::pull(date_start) |>
            unique() |>
            min() |>
            format.Date("%e %B %Y"),
          " and ",
          frequency_distribution_df |>
            dplyr::pull(date_stop) |>
            unique() |>
            max() |>
            format.Date("%e %B %Y")
        )
      )
    )
}
