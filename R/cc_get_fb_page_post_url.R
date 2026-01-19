#' Extract urls included in posts shared on Facebook pages
#'
#' Extracts both urls explicitly shared, as well as those included in the message of the post.
#'
#' @param posts_df A data frame created with [cc_get_fb_page_posts()].
#'
#' @returns A data frame, including an `url_share` column (with urls explicitly shared), `url_message` column for url shared in the main text of the post, and `url_all`, combining the previous two and dropping NA.
#' @export
#'
#' @examples
#' \dontrun{
#' url_all_df <- cc_get_fb_page_posts(only_cached = TRUE, process_json = TRUE) |>
#'   cc_get_fb_page_post_url()
#'
#' url_all_df |>
#'   tidyr::unnest("url_all") |>
#'   dplyr::select(c("created_time", "id", "url_all"))
#'   }
cc_get_fb_page_post_url <- function(posts_df) {
  url_all_df <- posts_df |>
    dplyr::select(dplyr::any_of(c(
      "created_time",
      "id",
      "permalink_url",
      "message",
      "attachments"
    ))) |>
    tidyr::unnest(attachments) |>
    tidyr::unnest(attachments) |>
    tidyr::unnest(
      cols = dplyr::any_of(c("description", "title", "type", "url"))
    ) |>
    dplyr::mutate(
      url_share = URLdecode(url) |>
        stringr::str_remove(
          pattern = stringr::fixed("https://l.facebook.com/l.php?u=")
        ) |>
        stringr::str_remove(pattern = stringr::regex("&h=.*"))
    ) |>
    dplyr::mutate(
      url_message = stringr::str_extract_all(
        string = description,
        pattern = "https?://[\\w\\d./?=#-]+"
      )
    ) |>
    dplyr::rename(target_title = title) |>
    dplyr::select(dplyr::any_of(c(
      "created_time",
      "id",
      "permalink_url",
      "message",
      "type",
      "target_title",
      "url_share",
      "url_message"
    ))) |>
    dplyr::mutate(
      url_share = dplyr::if_else(
        condition = .data[["type"]] == "share",
        true = url_share,
        false = NA_character_,
        missing = NA_character_
      )
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      url_all = list(as.character(na.omit(
        dplyr::c_across(
          dplyr::all_of(c("url_share", "url_message"))
        )
      )))
    ) |>
    dplyr::ungroup()

  url_all_df
}
