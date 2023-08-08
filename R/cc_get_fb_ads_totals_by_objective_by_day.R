#' Get total Facebook ad spending per day by objective and as a rolling average
#'
#' @param ads_df A data frame, such as the one retrieved with `cc_get_fb_ads()`
#' @param before Defaults to 3. Days to keep before the given day for calculating rolling averages.
#' @param after Defaults to 3. Days to keep after the given day for calculating rolling averages.
#' @inheritParams cc_set
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_ads_totals_by_day_by_objective <- function(ads_df = NULL,
                                                     start_date = NULL,
                                                     end_date = NULL,
                                                     before = 3,
                                                     after = 3) {
  dates_l <- cc_get_settings(
    start_date = start_date,
    end_date = end_date
  )

  start_date <- dates_l$start_date
  end_date <- dates_l$end_date

  if (is.null(ads_df)) {
    ads_df <- cc_get_fb_ads(start_date = start_date, end_date = end_date)
  }

  dplyr::left_join(
    x = tibble::tibble(date = seq.Date(
      from = as.Date(start_date),
      to = as.Date(end_date),
      by = "day"
    )),
    y = ads_df,
    multiple = "all",
    by = "date"
  ) |>
    dplyr::mutate(spend = as.numeric(spend)) |>
    tidyr::replace_na(replace = list(spend = 0)) |>
    dplyr::group_by(objective, date) |>
    dplyr::summarise(
      spend_per_day = sum(as.numeric(spend)),
      .groups = "drop"
    ) |>
    dplyr::mutate(date = lubridate::as_date(date)) |>
    tidyr::complete(date,
      objective,
      fill = list(spend_per_day = 0)
    ) |>
    dplyr::group_by(objective) |>
    dplyr::mutate(
      rolling_spend_per_day = slider::slide_index_dbl(
        .x = spend_per_day,
        .f = mean,
        .i = date,
        .before = lubridate::days(before),
        .after = lubridate::days(after)
      )
    ) |>
    dplyr::ungroup()
}
