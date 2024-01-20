#' Get Facebook page token
#'
#' @param fb_user_id Facebook used id. If not known, can be retrieved with `cc_get_fb_user()`.
#' @param page_id Exact page id. See `cc_get_fb_managed_pages()` for pages you have access to.
#' @param page_name Exact page name. See `cc_get_fb_managed_pages()` for pages you have access to.
#' @param token User token.
#'
#' @return A character vector of length one with the Facebook token.
#' @export
#'
#' @examples
#' cc_get_fb_page_token(
#'   fb_user_id = cc_get_fb_user(),
#'   page_name = "My example page"
#' )
cc_get_fb_page_token <- function(fb_user_id = NULL,
                                 page_id = NULL,
                                 page_name = NULL,
                                 fb_user_token = NULL) {
  pages_df <- cc_get_fb_managed_pages(
    fb_user_id = fb_user_id,
    fb_user_token = fb_user_token,
    fields = c("id", "name", "access_token")
  )

  if (is.null(page_id) == FALSE) {
    pages_df |>
      dplyr::filter(as.character(id) == as.character(page_id)) |>
      dplyr::pull(access_token)
  } else if (is.null(page_name) == FALSE) {
    pages_df |>
      dplyr::filter(as.character(name) == as.character(page_name)) |>
      dplyr::pull(access_token)
  } else {
    cli::cli_abort("Either {.var page_id} or {.var page_name} must be given.")
  }
}
