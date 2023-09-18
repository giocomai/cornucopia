#' Get Facebook user id and name, as well as other options fields
#'
#' For details, see:
#' \url{https://developers.facebook.com/docs/graph-api/reference/user/}
#'
#' @fields A character vector of valid fields. Defaults to `c("id", "name)`.
#'   Valid values include:
#'   `c("short_name","first_name","last_name","middle_name","name_format","picture")
#' @format Defaults to "data.frame". If list, a list is returned instead; mostly
#'   useful when the "picture" field is requested.
#' @inheritParams cc_get_instagram_user
#'
#' @return By default, a data frame with one row and two character columns,
#'   "name" and "id".
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_user()
#' }
cc_get_fb_user <- function(token = NULL,
                           fields = c(
                             "id",
                             "name"
                           ),
                           format = "data.frame") {
  if (is.null(token)) {
    fb_user_token <- cc_get_settings(fb_user_token = token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(token)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/"
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append("me") |>
    httr2::req_url_query(
      access_token = fb_user_token,
      fields = stringr::str_flatten(fields, collapse = ",")
    )

  req <- httr2::req_perform(req = api_request)

  if (format == "data.frame") {
    httr2::resp_body_json(req) |>
      tibble::as_tibble()
  } else {
    httr2::resp_body_json(req)
  }
}
