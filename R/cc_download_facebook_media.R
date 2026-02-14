#' Downloads media or previews of Facebook posts
#'
#' @param posts_df Defaults to `NULL`. If given, expected to be a data frame
#'   generated with [cc_get_fb_page_posts()].
#' @param type Defaults to "full_picture", type of media to download. Other
#'   options not yet implemented.
#' @param path Path to the folder where files will be downloaded; defaults to
#'   `fb_full_picture`, depending on `type`. If the path does
#'   not exist, it will be created.
#' @param wait Defaults to 1. Time to wait between downloading each file.
#' @param ... Passed to [cc_get_fb_page_posts()].
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
cc_download_facebook_media <- function(
  posts_df = NULL,
  type = c("full_picture"),
  path = NULL,
  wait = 1,
  ...
) {
  current_type <- type[[1]]

  if (is.null(path)) {
    path <- fs::dir_create(
      path = stringr::str_flatten(string = c("fb_", current_type))
    )
  }

  if (is.null(posts_df)) {
    posts_df <- cc_get_fb_page_posts(...)
  }

  url_column <- stringr::str_flatten(
    string = c(current_type, "url"),
    collapse = "_"
  )

  if (current_type == "full_picture") {
    filename_df <- posts_df |>
      dplyr::select(dplyr::all_of(c("id", "full_picture"))) |>
      tidyr::drop_na("full_picture") |>
      dplyr::rename(filename = "id", full_picture_url = full_picture) |>
      dplyr::mutate(
        extension = .data[[url_column]] |>
          stringr::str_remove(pattern = "\\?.*$") |>
          fs::path_ext()
      ) |>
      dplyr::mutate(
        media_path = fs::path(path, stringr::str_c(filename, ".", extension))
      ) |>
      tidyr::drop_na("media_path")
  }

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
