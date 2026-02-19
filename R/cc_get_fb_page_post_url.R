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
cc_get_fb_page_post_url <- function(posts_df = NULL, ...) {
  if (is.null(posts_df)) {
    posts_df <- cc_get_fb_page_posts(...)
  }

  posts_with_url_df <- posts_df |>
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
        string = message,
        pattern = "https?://[\\w\\d./?=#-]+"
      )
      # ,
      # url_description = stringr::str_extract_all(
      #   string = description,
      #   pattern = "https?://[\\w\\d./?=#-]+"
      # )
    ) |>
    dplyr::rename(target_title = title) |>
    dplyr::select(dplyr::any_of(c(
      "created_time",
      "id",
      "permalink_url",
      "message",
      "description",
      "type",
      "target_title",
      "url_share",
      "url_message"
      # ,
      # "url_description"
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
          dplyr::any_of(c("url_share", "url_message", "url_description"))
        )
      )))
    ) |>
    dplyr::ungroup() |>
    tidyr::unnest(url_all)

  posts_with_url_df
}


#' Extract url posted in comments
#'
#' @param comments_df A data frame created with [cc_get_fb_page_post_comments()].
#' @inheritParams cc_get_fb_page_post_url
#'
#' @returns A data frame, similar to `comments_df`, but with an additional `url_message` column.
#' @export
#'
#' @examples
cc_get_fb_page_post_comment_url <- function(
  comments_df,
  posts_df = NULL,
  only_own_comments = TRUE,
  fb_page_id = NULL
) {
  if (is.null(comments_df)) {
    comments_df <- cc_get_fb_page_post_comments(fb_post_id = posts_df)
  }

  fb_page_id <- cc_get_settings(fb_page_id = fb_page_id)[["fb_page_id"]]

  if (only_own_comments) {
    comments_df <- comments_df |>
      dplyr::filter(from_id == fb_page_id)
  }

  comments_with_url_df <- comments_df |>
    dplyr::filter_out(is.na(created_time)) |>
    dplyr::mutate(
      url_message = stringr::str_extract_all(
        string = message,
        pattern = "https?://[\\w\\d./?=#-]+"
      )
    ) |>
    tidyr::unnest(url_message)

  comments_with_url_df
}


#' Retrieve urls posted in a Facebook page, no matter if as attachment, in the
#' message of a post, or in a comment
#'
#' @param posts_with_url_df A data frame created with
#'   [cc_get_fb_page_post_url()].
#' @param comments_with_url_df A data frame created with
#'   [cc_get_fb_page_post_comment_url()].
#'
#' @returns A data frame, with url and reference to Facebook post identifier.
#' @export
#'
#' @examples
cc_get_fb_page_post_url_combo <- function(
  posts_with_url_df,
  comments_with_url_df
) {
  posts_processed_df <- posts_with_url_df |>
    dplyr::rename(
      fb_post_id = id,
      permalink_post = permalink_url,
      url = url_all,
      fb_post_type = type
    ) |>
    dplyr::mutate(
      url_source = dplyr::case_when(
        fb_post_type == "share" ~ "attachment",
        TRUE ~ "post"
      )
    ) |>
    dplyr::select(
      dplyr::all_of(
        x = c("created_time", "fb_post_id", "fb_post_type", "url_source", "url")
      )
    )

  comments_processed_df <- comments_with_url_df |>
    dplyr::left_join(
      y = posts_with_url_df |>
        dplyr::transmute(fb_post_id = id, fb_post_type = type) |>
        dplyr::distinct(fb_post_id, .keep_all = TRUE),
      by = "fb_post_id",
      relationship = "many-to-one"
    ) |>
    dplyr::mutate(url_source = "comment") |>
    dplyr::rename(url = url_message) |>
    dplyr::select(
      dplyr::all_of(
        x = c("created_time", "fb_post_id", "fb_post_type", "url_source", "url")
      )
    )

  combo_url_df <- dplyr::bind_rows(posts_processed_df, comments_processed_df) |>
    dplyr::arrange(created_time)

  combo_url_df
}
