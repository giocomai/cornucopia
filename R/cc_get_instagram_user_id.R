#' Get the Instagram user id of a Page's Instagram Business Account
#'
#' For details, see step 5 of this guide: \url{https://developers.facebook.com/docs/instagram-api/getting-started/}
#'
#' @param fb_user_token Facebook user token (not a page token).
#'
#' @return
#' @export
#'
#' @examples
cc_get_instagram_user_id <- function(
  fb_page_id = NULL,
  fb_user_token = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version()
) {
  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  if (is.null(fb_page_id)) {
    fb_page_id <- cc_get_settings(fb_page_id = fb_page_id) |>
      purrr::pluck("fb_page_id")
  } else {
    fb_page_id <- as.character(fb_page_id)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/"
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(meta_api_version) |>
    httr2::req_url_path_append(fb_page_id) |>
    httr2::req_url_query(
      fields = "instagram_business_account",
      access_token = fb_user_token,
    )

  instagram_user_id_l <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (is.null(instagram_user_id_l[["error"]][["message"]]) == FALSE) {
    cli::cli_abort(instagram_user_id_l[["error"]][["message"]])
  }

  instagram_user_id_l |>
    purrr::pluck("instagram_business_account", "id")
}
