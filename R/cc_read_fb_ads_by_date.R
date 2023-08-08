#' Reads locally stored dated files, typically generated with `cc_get_fb_ads_by_date`
#'
#' @param path Path to dated files
#' @param start_date Defaults to NULL. If given, only files retrieved on this date or later are included. Input should be of date class, or on the YYYY-MM-DD format.
#' @param end_date Defaults to NULL. If given, only files retrieved on this date or sooner are included. Input should be of date class, or on the YYYY-MM-DD format.
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   cc_read_fb_ads_by_date()
#' }
#' }
cc_read_fb_ads_by_date <- function(path = "fb_ads_by_date_rds",
                                   start_date = NULL,
                                   end_date = NULL) {
  rds_files_v <- fs::dir_ls(
    path = path,
    recurse = FALSE,
    type = "file",
    glob = "*.rds"
  )

  dated_path_df <- tibble::tibble(path = rds_files_v) |>
    dplyr::mutate(date = fs::path_file(rds_files_v) |>
      fs::path_ext_remove() |>
      lubridate::as_date())

  if (is.null(start_date) == FALSE) {
    dated_path_df <- dated_path_df |>
      dplyr::filter(date >= lubridate::as_date(start_date))
  }

  if (is.null(end_date) == FALSE) {
    dated_path_df <- dated_path_df |>
      dplyr::filter(date <= lubridate::as_date(end_date))
  }

  purrr::map(
    .x = purrr::transpose(dated_path_df),
    .f = function(x) {
      readr::read_rds(file = x$path) |>
        dplyr::mutate(date = lubridate::as_date(x$date))
    }
  ) |>
    purrr::list_rbind()
}
