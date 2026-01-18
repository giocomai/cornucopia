#' Process data frame with json columns and turn them into lists
#'
#' Columns with names starting with `json_` are assumed to contain json as
#' strings and will be processed. All the rest will be ignored. This function is
#' mostly used to process data cached locally and stored as a json string in
#' order to prevent database limitations. They are not initially processed, as
#' the structure of some data may vary significantly across different cases.
#' Used e.g. to process data cached locally with [cc_get_fb_page_posts()].
#'
#' @param df A data frame, with columns starting with `json_`, that are
#'   effectively character vectors with json-formatted data as strings, such as
#'   those generated with [cc_get_fb_page_posts()].
#'
#' @returns A data frame, with the same number of columns as the input. All
#'   columns with names originally starting with `json_` have been processed
#'   into lists, and the prefix `json_` removed from the column name.
#' @export
#'
#' @examples
#' \dontrun{
#'   posts_df <- cc_get_fb_page_posts()
#'
#'   posts_df |>
#'    cc_process_json() |>
#'    tidyr::unnest(attachments)
#' }
cc_process_json <- function(df) {
  df |>
    dplyr::mutate(dplyr::across(
      .cols = dplyr::starts_with("json_"),
      .fns = ~ purrr::map(
        .x = .x,
        .f = \(current_json_string) {
          if (is.na(current_json_string)) {
            return(NA)
          } else {
            yyjsonr::read_json_str(current_json_string)
          }
        }
      )
    )) |>
    dplyr::rename_with(.fn = ~ stringr::str_remove(.x, "json_"))
}
