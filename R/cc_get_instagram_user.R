#' Get information about your Instagram user
#'
#' If you need to retrieve your Instagram user id, consider
#' `cc_get_instagram_user_id()`.
#'
#' See the relevant page in the documentation for available fields and more
#' details https://developers.facebook.com/docs/instagram-api/reference/ig-user
#'
#' Look in particular at the permissions requirements. If you have issues,
#' consider dropping `shopping_product_tag_eligibility` from the fields, as it
#' requires additional permissions.
#'
#' @param ig_user_id Instagram user id, typically composed of 17 digits. Not to
#'   be confused with legacy Instagram account id.
#' @param fields Defaults to all available (except
#'   "shopping_product_tag_eligibility", which requires dedicated permissions).
#'   Consider reducing if you don't have all relevant permissions.
#' @inheritParams cc_set
#'
#' @return A data frame (a tibble), with a column for id, plus as many columns
#'   as the requested fields.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_instagram_user()
#' }
cc_get_instagram_user <- function(
  ig_user_id = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
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
  fb_user_token = NULL
) {
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
    meta_api_version
  )

  fields_v <- stringr::str_c(fields, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(ig_user_id) |>
    httr2::req_url_query(
      fields = fields_v,
      access_token = fb_user_token
    )

  response_l <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (is.null(response_l[["error"]][["message"]]) == FALSE) {
    cli::cli_abort(response_l[["error"]][["message"]])
  }

  tibble::as_tibble(response_l)
}
