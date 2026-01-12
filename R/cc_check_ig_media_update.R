#' Check when information about Instagram media should be updated based on a
#' simple heuristic
#'
#' Update is set to TRUE if:
#'
#' - media has been published in the last week and not retrieved today
#' - media has been published in the last month and not retrieved in the last week
#' - media has been published in the last year and not retrieved in the last month
#' - media has not been retrieved in the last year
#'
#'
#' @inheritParams cc_get_instagram_media
#'
#' @return A tibble with four columns: `ig_media_id` (a character column),
#'   `date_created` and `date_retrieved` (Date columns), and an `update` column
#'   (logical)
#' @export
#'
#' @examples
cc_check_instagram_media_update <- function(
  ig_media_id = NULL,
  ig_user_id = NULL,
  insights = FALSE,
  fb_user_token = NULL
) {
  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  if (ig_user_id == "") {
    cli::cli_abort("`ig_user_id` must be given when `cache` is set to TRUE.")
  }

  media_df <- cc_get_instagram_media(
    ig_media_id = ig_media_id,
    ig_user_id = ig_user_id,
    cache = TRUE,
    update = FALSE,
    fb_user_token = fb_user_token
  )

  if (insights) {
    insights_df <- cc_get_instagram_media_insights(
      ig_media_id = ig_media_id,
      ig_user_id = ig_user_id,
      cache = TRUE,
      update = FALSE,
      fb_user_token = fb_user_token
    ) |>
      dplyr::select(dplyr::all_of(c("ig_media_id", "timestamp_retrieved")))

    media_df <- media_df |>
      dplyr::select(!"timestamp_retrieved") |>
      dplyr::left_join(
        y = insights_df,
        by = "ig_media_id"
      )
  }

  today <- Sys.Date()

  media_dates_df <- media_df |>
    dplyr::transmute(
      ig_media_id,
      date_created = lubridate::as_date(.data[["timestamp"]]),
      date_retrieved = lubridate::as_date(.data[["timestamp_retrieved"]])
    ) |>
    dplyr::arrange(dplyr::desc(.data[["date_retrieved"]])) |>
    dplyr::distinct(.data[["ig_media_id"]], .keep_all = TRUE) |>
    dplyr::mutate(
      created_last7 = ((today - date_created) <= 7),
      created_last31 = ((today - date_created) <= 31),
      created_last365 = ((today - date_created) <= 365),
      retrieved_today = ((today - date_retrieved) < 1),
      retrieved_last7 = ((today - date_retrieved) <= 7),
      retrieved_last31 = ((today - date_retrieved) <= 31),
      retrieved_last365 = ((today - date_retrieved) <= 365)
    )

  media_dates_df |>
    dplyr::mutate(
      update = dplyr::case_when(
        created_last7 & !retrieved_today ~ TRUE,
        created_last31 & !retrieved_last7 ~ TRUE,
        created_last365 & !retrieved_last31 ~ TRUE,
        !retrieved_last365 ~ TRUE,
        .default = FALSE
      )
    ) |>
    dplyr::select(
      -(dplyr::starts_with("created")),
      -(dplyr::starts_with("retrieved"))
    )
}
