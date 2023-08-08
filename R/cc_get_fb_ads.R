#' Get details about Facebook ads
#'
#' Caches data in the folder `fb_ads_by_date_rds` in the current working
#' directory.
#'
#' See also `cc_get_fb_ads_by_date()` for customisation of fields.
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
                          only_cached = FALSE) {
  dates_l <- cc_get_settings(
    start_date = start_date,
    end_date = end_date
  )

  start_date <- dates_l$start_date
  end_date <- dates_l$end_date

  dates <- as.Date(start_date:end_date,
    origin = as.Date("1970-01-01")
  )

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

  names(dates) <- dates

  df <- purrr::map_dfr(
    .x = rev(dates),
    .f = function(x) {
      cc_get_fb_ads_by_date(date = x)
    },
    .id = "date"
  ) |>
    dplyr::mutate(date = lubridate::as_date(date)) |>
    dplyr::filter(date >= start_date, date <= end_date)
}
