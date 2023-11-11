#' Get managed pages, including name, page token, and id
#'
#' @param fb_user_id Facebook user id. Defaults to NULL, can be set with
#'   `cc_set()`. Can be retrieved with `cc_get_fb_user()`.
#' @inheritParams cc_get_instagram_user
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_managed_pages()
#' }
cc_get_fb_managed_pages <- function(fb_user_id = NULL,
                                    fields = c("name", "access_token"),
                                    fb_user_token = NULL) {
  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  if (is.null(fb_user_id)) {
    fb_user_id <- cc_get_settings(fb_user_id = fb_user_id) |>
      purrr::pluck("fb_user_id")
  } else {
    fb_user_id <- as.character(fb_user_id)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/"
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_user_id) |>
    httr2::req_url_path_append("accounts") |>
    httr2::req_url_query(
      access_token = fb_user_token,
      fields = stringr::str_flatten(fields, collapse = ",")
    )

  req <- httr2::req_perform(req = api_request)

  managed_pages_l <- httr2::resp_body_json(req)

  purrr::map(
    .x = managed_pages_l[["data"]],
    .f = \(x) {
      x |>
        tibble::as_tibble()
    }
  ) |>
    purrr::list_rbind()
}
