#' Get Facebook user id and name, as well as other options fields
#'
#' For details, see:
#' \url{https://developers.facebook.com/docs/graph-api/reference/user/}
#'
#' @fields A character vector of valid fields. Defaults to `c("id", "name)`.
#'   Valid values include:
#'   `c("short_name","first_name","last_name","middle_name","name_format","picture")
#' @format Defaults to "data.frame". If "list", a list is returned instead;
#'   useful e.g. when the "picture" field is requested. 
#' @inheritParams cc_set
#'
#' @return By default, a data frame with one row and two character columns,
#'   "name" and "id". Customisable with the `format` argument.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_user()
#' }
cc_get_fb_user <- function(fb_user_token = NULL,
                           fields = c(
                             "id",
                             "name"
                           ),
                           format = "data.frame") {
  
  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
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

  current_l <- api_request |> 
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |> 
    httr2::resp_body_json(req)

  if (is.null(current_l[["error"]][["message"]]) == FALSE) {
    cli::cli_abort(current_l[["error"]][["message"]])
  }
  
  if (format == "data.frame") {
    current_l |>
      tibble::as_tibble()
  } else {
    current_l
  }
}
