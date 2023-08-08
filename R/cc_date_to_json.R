#' Output date in a format that can be passed as custom date to the Facebok API.
#'
#' @param start_date A date.
#' @param end_date Defaults to NULL. If left to NULL, `end_date` is assumed to
#'   be the same as the start date
#'
#' @return
#' @export
#'
#' @examples
cc_date_to_json <- function(start_date,
                            end_date = NULL) {
  if (is.null(end_date) == TRUE) {
    end_date <- start_date
  }
  jsonlite::toJSON(
    list(
      since = start_date,
      until = end_date
    ),
    auto_unbox = TRUE
  )
}
