#' Get details about Facebook ads
#'
#' Caches data in the folder `fb_ads_by_date_rds` in the current working
#' directory.
#'
#' See also `cc_get_fb_ads_by_date()` for customisation of fields.
#'
#' For valid fields, see: \url{https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/}
#'
#' @param only_cached Defaults to FALSE. If TRUE, only pre-cached files within
#'   the given date range are loaded; no new calls to the API are made and
#'   reliably works offline.
#'
#' @return A data frame with an extensive number of fields, some presented as
#'   nested data frames.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_ads()
#' }
cc_get_fb_ads <- function(start_date = NULL,
                          end_date = NULL,
                          only_cached = FALSE,
                          fields = c(
                            "campaign_name",
                            "campaign_id",
                            "adset_name",
                            "adset_id",
                            "ad_name",
                            "ad_id",
                            "objective",
                            "account_currency",
                            "spend",
                            "actions",
                            "action_values",
                            "cost_per_action_type",
                            "cost_per_unique_action_type",
                            "conversions",
                            "cost_per_conversion",
                            "conversion_rate_ranking",
                            "cpc",
                            "cpm",
                            "cpp",
                            "ctr",
                            "frequency",
                            "reach"
                          )) {
  dates_l <- cc_get_settings(
    start_date = start_date,
    end_date = end_date
  )

  start_date <- dates_l$start_date
  end_date <- dates_l$end_date

  dates <- as.Date(start_date:end_date,
    origin = as.Date("1970-01-01")
  )

  names(dates) <- dates

  if (only_cached == TRUE) {
    cached_v <- fs::dir_ls(
      path = "fb_ads_by_date_rds",
      recurse = FALSE,
      type = "file",
      glob = "*.rds"
    ) |>
      fs::path_file() |>
      fs::path_ext_remove() |>
      lubridate::as_date()
    dates <- dates[dates %in% cached_v]
  }

  df <- purrr::map_dfr(
    .x = rev(dates),
    .f = function(x) {
      cc_get_fb_ads_by_date(
        date = x,
        fields = fields
      )
    },
    .id = "date"
  ) |>
    dplyr::mutate(date = lubridate::as_date(date)) |>
    dplyr::filter(date >= start_date, date <= end_date)
}
