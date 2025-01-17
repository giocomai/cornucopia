#' Retrieve information about a user through Instagram's business discovery
#'
#' This function allows you to retrieve basic information about an Instagram account you are not associated with, as long as they are a business account.
#'
#' [More details about Business Discovery and relevant permissions](https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/business_discovery/).
#'
#' @inheritParams cc_get_instagram_bd_user_media
#'
#' @returns
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive) {
#'   # e.g. to retrieve information about the Instagram account of the United Nations
#'   cc_get_instagram_bd_user(ig_username = "unitednations")
#' }
#' }
cc_get_instagram_bd_user <- function(ig_username,
                                     fields = c(
                                       "id",
                                       "ig_id",
                                       "username",
                                       "name",
                                       "biography",
                                       "website",
                                       "followers_count",
                                       "follows_count",
                                       "media_count",
                                       "profile_picture_url"
                                     ),
                                     api_version = "v21.0",
                                     ig_user_id = NULL,
                                     fb_user_token = NULL) {
  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  fields_v <- stringr::str_c(fields, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(ig_user_id) |>
    httr2::req_url_query(
      fields = stringr::str_c(
        "business_discovery.username(",
        ig_username,
        "){",
        fields_v,
        "}"
      ),
      access_token = fb_user_token
    )

  response <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  response_l <- response |>
    httr2::resp_body_json()

  if (is.null(response_l[["error"]][["message"]]) == FALSE) {
    cli::cli_abort(response_l[["error"]][["message"]])
  }

  tibble::as_tibble(response_l[["business_discovery"]])
}
