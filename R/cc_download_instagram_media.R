#' Downloads Instagram media or thumbnails
#'
#' @param media_df Defaults to `NULL`. If given, expected to be a data frame generated with [cc_get_instagram_media()].
#' @param type Defaults to "media", type of media to download. The only alternative valid value is "thumbnail".
#' @param path Path to the folder where files will be downloaded; defaults to either `ig_media` or `ig_thumbnail`, depending on `type`. If the path does not exist, it will be created.
#' @param wait Defaults to 1. Time to wait between downloading each file.
#' @param ... Passed to [cc_get_instagram_media()].
#'
#' @returns Nothing, used for its side effects.
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'    cc_download_instagram_media()
#' }
#' }
cc_download_instagram_media <- function(
  media_df = NULL,
  type = c("media", "thumbnail"),
  path = NULL,
  wait = 1,
  ...
) {
  current_type <- type[[1]]

  if (is.null(path)) {
    path <- fs::dir_create(
      path = stringr::str_flatten(string = c("ig_", current_type))
    )
  }

  if (is.null(media_df)) {
    media_df <- cc_get_instagram_media(...)
  }

  url_column <- stringr::str_flatten(
    string = c(current_type, "url"),
    collapse = "_"
  )

  filename_df <- media_df |>
    tidyr::unite(
      "shortcode",
      "ig_id",
      "ig_media_id",
      col = "filename",
      remove = FALSE
    ) |>
    dplyr::mutate(
      extension = .data[[url_column]] |>
        stringr::str_remove(pattern = "\\?.*$") |>
        fs::path_ext()
    ) |>
    dplyr::mutate(
      media_path = fs::path(path, stringr::str_c(filename, ".", extension))
    )

  available_files_df <- tibble::tibble(media_path = fs::dir_ls(path = path))

  media_to_download_df <- filename_df |>
    dplyr::anti_join(y = available_files_df, by = dplyr::join_by("media_path"))

  purrr::walk2(
    .progress = "Downloading {current_type}",
    .x = media_to_download_df[[url_column]],
    .y = media_to_download_df[["media_path"]],
    .f = function(current_url, current_path) {
      download.file(
        url = current_url,
        destfile = current_path
      )
      Sys.sleep(time = wait)
    }
  )
}
