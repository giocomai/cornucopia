#' Return a tibble with details about all the stats files exported from LinkedIn
#' Pages
#'
#' Provide a path to a local folder where a bunch of files with names such as
#' "pagename_followers_1684688073420.xls" are stored. The path will be scanned
#' recursively and a tidy data framre returned, including columns with the name
#' of the page, the type of stats included in each file, as well as the date
#' when the data have been exported.
#'
#' @param path A path to a folder to be scanned recursively
#'
#' @return
#' @export
#'
#' @examples
cc_get_linkedin_stats_files <- function(path) {
  if (fs::dir_exists(path) == FALSE) {
    cli::cli_abort(message = "Folder does not exist.")
  }

  all_files <- fs::dir_ls(
    path = path,
    all = FALSE,
    recurse = TRUE,
    type = "file",
    glob = "*.xls"
  )

  stats_files_df <- tibble::tibble(path = all_files) |>
    dplyr::mutate(filename = fs::path_file(all_files) |>
      fs::path_ext_remove()) |>
    dplyr::mutate(datetime = lubridate::as_datetime(as.numeric(stringr::str_extract(
      string = filename,
      pattern = "[[:digit:]]+$"
    )) / 1000)) |>
    dplyr::mutate(date = lubridate::as_date(datetime)) |>
    dplyr::mutate(page = stringr::str_remove(
      string = filename,
      pattern = "_[[:digit:]]+$"
    )) |>
    dplyr::mutate(type = stringr::str_extract(
      string = page,
      pattern = "[[:alpha:]]+$"
    )) |>
    dplyr::mutate(page = stringr::str_remove(
      string = page,
      pattern = "_[[:alpha:]]+$"
    )) |>
    dplyr::arrange(page, type, datetime)

  stats_files_df
}
