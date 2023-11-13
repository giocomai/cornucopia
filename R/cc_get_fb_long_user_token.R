#' Get a long-lived user access token for Facebook
#'
#' For details, see
#' \url{https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived/}
#'
#' You should use as input a short-lived user access token. In future calls, you
#' can then routinely use your newly aquired long-lived user access token, which
#' should generally last about 60 days.
#'
#' @inheritParams cc_get_fb_page_token
#'
#' @return A character vector of length one, with the long-loved user access token.
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive) {
#'   cc_get_fb_long_user_token(
#'     fb_user_token = "your_short_term_token_here",
#'     fb_app_id = "your_fb_app_id_here",
#'     fb_app_secret = "your_fb_app_secret_here"
#'   )
#' }
#' }
#'
cc_get_fb_long_user_token <- function(fb_user_token = NULL,
                                      fb_app_id = NULL,
                                      fb_app_secret = NULL,
                                      api_version = "v18.0") {
  base_url <- stringr::str_c(
    "https://graph.facebook.com/"
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(api_version) |>
    httr2::req_url_path_append("oauth") |>
    httr2::req_url_path_append("access_token") |>
    httr2::req_url_query(
      grant_type = "fb_exchange_token",
      client_id = fb_app_id,
      client_secret = fb_app_secret,
      fb_exchange_token = fb_user_token
    )

  req <- httr2::req_perform(req = api_request)

  long_token_l <- httr2::resp_body_json(req)

  long_token_l[["access_token"]]
}
