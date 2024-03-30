#' Calculate the ratio of two Google Analytics events
#'
#' @param events A character vector of length 2, such as `c("session_start", "purchase")` to calculate the ratio between these two events.
#' @param rolling If TRUE, calculates a rolling mean over the number of periods (by default, days) set with `rolling_before` and `rolling_after`.
#' @param rolling_complete Defaults to FALSE. If TRUE, rolling mean is calculated only for periods that are fully available.
#' @inheritParams cc_set
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive) {
#'   cc_get_ga_event_ratio(c("session_start", "purchase"))
#' }
#' }
#'
cc_get_ga_event_ratio <- function(events,
                                  rolling = FALSE,
                                  rolling_before = 7,
                                  rolling_after = 7,
                                  rolling_period = "day",
                                  rolling_complete = FALSE,
                                  start_date = NULL,
                                  end_date = NULL,
                                  ga_email = NULL,
                                  ga_property_id = NULL) {
  if (!(is.character(events) & length(events) == 2)) {
    cli::cli_abort("{.par events} must be a character vector of length 2.")
  }

  if (is.null(ga_email)) {
    ga_email <- cc_get_settings(ga_email = ga_email) |>
      purrr::pluck("ga_email")
  } else {
    ga_email <- as.character(ga_email)
  }

  if (is.null(ga_property_id)) {
    ga_property_id <- cc_get_settings(ga_property_id = ga_property_id) |>
      purrr::pluck("ga_property_id")
  } else {
    ga_property_id <- as.character(ga_property_id)
  }

  if (is.null(start_date)) {
    start_date <- cc_get_settings(start_date = start_date) |>
      purrr::pluck("start_date")
  } else {
    start_date <- as.character(start_date)
  }

  if (is.null(end_date)) {
    end_date <- cc_get_settings(end_date = end_date) |>
      purrr::pluck("end_date")
  } else {
    end_date <- as.character(end_date)
  }

  date_range <- c(as.character(start_date), as.character(end_date))

  quiet_ga_auth <- purrr::quietly(googleAnalyticsR::ga_auth)
  ga_token <- quiet_ga_auth(email = ga_email)

  events_df <- googleAnalyticsR::ga_data(
    propertyId = ga_property_id,
    metrics = c("eventCount"),
    dimensions = c("date", "eventName"),
    date_range = date_range,
    dim_filters = googleAnalyticsR::ga_data_filter(eventName == events),
    limit = -1
  ) |>
    dplyr::mutate(eventName = factor(x = .data[["eventName"]], levels = events, ordered = TRUE)) |>
    tidyr::complete(date, eventName, fill = list(eventCount = 0)) |>
    dplyr::arrange(date, eventName)




  if (rolling) {
    events_df <- events_df |>
      dplyr::group_by(eventName) |>
      dplyr::mutate(
        eventCount = slider::slide_period_dbl(
          .x = eventCount,
          .f = mean,
          .i = date,
          .period = rolling_period,
          .before = rolling_before,
          .after = rolling_after,
          .complete = rolling_complete
        )
      )
  }
  events_share_df <- events_df |>
    tidyr::pivot_wider(
      names_from = eventName,
      values_from = eventCount
    ) |>
    dplyr::mutate(ratio = .data[[events[[2]]]] / .data[[events[[1]]]])

  events_share_df
}
