#' Get a long-lived page acess token for Facebook
#'
#' For details, see
#' \url{https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived/}
#'
#' You should use as input a long-lived user access token. Long-lived Page
#' access token do not have an expiration date and only expire or are
#' invalidated under certain conditions.
#'
#' @param fb_user_id App-scoped user id. This can be retrieved with
#'   `cc_get_fb_user()`
#' @param fb_user_token Must be a long-lived user token. This can be retrieved
#'   with `cc_get_fb_long_user_token()`.
#' @inheritParams cc_get_fb_page_token
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_long_page_token <- function(fb_user_id = NULL,
                                      fb_user_token = NULL,
                                      api_version = "v18.0") {
  base_url <- stringr::str_c(
    "https://graph.facebook.com/"
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(api_version) |>
    httr2::req_url_path_append(fb_user_id) |>
    httr2::req_url_path_append("accounts") |>
    httr2::req_url_query(
      access_token = fb_user_token,
    )

  req <- httr2::req_perform(req = api_request)

  long_token_l <- httr2::resp_body_json(req)

  long_page_token_df <- purrr::map(
    .x = long_token_l[["data"]],
    .f = \(x) {
      tibble::tibble(
        page_name = x[["name"]],
        page_id = x[["id"]],
        access_token = x[["access_token"]],
        category_name = x[["category_list"]][[1]][["name"]],
        category_id = x[["category_list"]][[1]][["id"]],
        tasks = list(tibble::tibble(tasks = unlist(x[["tasks"]])))
      )
    }
  ) |>
    purrr::list_rbind()

  long_page_token_df
}
