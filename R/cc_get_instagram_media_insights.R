#' Get insights about a given Instagram post based on its ig_media_id
#'
#' It retrieves the requested fields from the APIs and introduces a few
#' adjustments:
#'
#' - it always includes the media id, in a column named `ig_media_id`
#' - it always include the media type, in a column named `ig_media_type`
#' - it adds a `timestamp_retrieved` column, with ISO 8601-formatted creation date in UTC
#' - it ensures that the output always included all requested fields, if they are valid; e.g. `is_shared_to_feed` and `media_url` may be omitted by the API (see documentation) but this function always includes the relevant column (and returns a NA value if no value is given)
#' - all valid fields for the given API endpoint are always requested and cached locally; only requested fields are effectively returned (but `ig_media_id` and `timestamp_retrieved` are always included as first and last column)
#'
#' N.B.: different media types have different fields: hence the `NA`s in columns
#' for which data are unavailable for the given media type.
#' N.B.: all media posted before 2017 are discarded by default, as Instagram API throw an error for earlier posts
#'
#' For details, see:
#' https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights
#'
#' @param ig_media_id Instagram media identifier. A list of identifiers for your
#'   account can be retrieved with `cc_get_instagram_media_id()`. If left to
#'   NULL, a full list is automatically retrieved.
#' @inheritParams cc_get_instagram_media_id
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_instagram_media_insights()
#' }
cc_get_instagram_media_insights <- function(ig_media_id = NULL,
                                            metrics = NULL,
                                            api_version = "v18.0",
                                            ig_user_id = NULL,
                                            cache = TRUE,
                                            update = TRUE,
                                            token = NULL) {
  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  if (ig_user_id == "" & cache == TRUE) {
    cli::cli_abort("`ig_user_id` must be given when `cache` is set to TRUE.")
  }

  if (is.null(ig_media_id)) {
    ig_media_id <- cc_get_instagram_media_id(
      ig_user_id = ig_user_id,
      api_version = api_version,
      token = token,
      cache = cache
    ) |>
      dplyr::pull(ig_media_id)
  }

  # Group by type of media and process separately
  media_df <- cc_get_instagram_media(
    ig_media_id = ig_media_id,
    api_version = api_version,
    ig_user_id = ig_user_id,
    cache = cache,
    token = token
  ) |>
    dplyr::mutate(media_type = stringr::str_to_lower(dplyr::if_else(condition = media_product_type == "REELS",
      true = "REELS",
      false = media_type
    ))) |>
    dplyr::mutate(date = lubridate::as_date(timestamp))

  # drop early posts as not available
  unavailable_media_df <- media_df |>
    dplyr::filter(date < as.Date("2017-01-01"))

  ig_media_id_available <- ig_media_id[!(ig_media_id %in% unavailable_media_df$ig_media_id)]

  if (length(ig_media_id_available) < length(ig_media_id)) {
    cli::cli_warn("Media posted before 2017 have been dropped as Insights are not available for earlier posts")
    ig_media_id <- ig_media_id_available
    media_df <- media_df |>
      dplyr::filter(date >= as.Date("2017-01-01"))
  }

  media_by_type <- media_df |>
    dplyr::group_by(media_type) |>
    dplyr::count() |>
    dplyr::ungroup()


  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
    }
    fs::dir_create("cornucopia_db")

    db <- DBI::dbConnect(
      drv = RSQLite::SQLite(),
      fs::path(
        "cornucopia_db",
        fs::path_ext_set(stringr::str_c("ig_", ig_user_id), ".sqlite") |>
          fs::path_sanitize()
      )
    )
  }

  all_types_output_df <- purrr::map(
    .x = media_by_type |> dplyr::pull(media_type) |> stringr::str_to_lower(),
    .f = function(current_media_type) {
      if (cache == TRUE) {
        current_table <- stringr::str_c(
          "ig_media_insights",
          "_",
          current_media_type
        )

        if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
          DBI::dbWriteTable(
            conn = db,
            name = current_table,
            value = cc_empty_instagram_media_insights[[current_media_type]]
          )
        }

        current_type_ig_media_id <- media_df |>
          dplyr::filter(media_type == current_media_type) |>
          dplyr::pull(ig_media_id)

        ig_media_all_requested_v <- current_type_ig_media_id

        previous_ig_media_df <- DBI::dbReadTable(
          conn = db,
          name = current_table
        ) |>
          dplyr::filter(ig_media_id %in% ig_media_all_requested_v) |>
          dplyr::collect() |>
          tibble::as_tibble()

        if (nrow(previous_ig_media_df) > 0) {
          previous_ig_media_df <- previous_ig_media_df |>
            dplyr::group_by(ig_media_id) |>
            dplyr::slice_max(order_by = timestamp_retrieved, n = 1, with_ties = FALSE) |>
            dplyr::ungroup()

          if (update == TRUE) {
            update_df <- cc_check_instagram_media_update(
              ig_media_id = unique(previous_ig_media_df$ig_media_id),
              ig_user_id = ig_user_id,
              insights = TRUE,
              token = token
            ) |>
              dplyr::filter(update == TRUE)

            if (nrow(update_df) > 0) {
              previous_ig_media_df <- previous_ig_media_df |>
                dplyr::anti_join(
                  y = update_df,
                  by = "ig_media_id"
                )
            }
          }
          previous_ig_media_id_v <- previous_ig_media_df |>
            dplyr::pull(ig_media_id)
        } else {
          previous_ig_media_id_v <- character()
        }
      } else {
        current_type_ig_media_id <- media_df |>
          dplyr::filter(media_type == current_media_type) |>
          dplyr::pull(ig_media_id)

        previous_ig_media_id_v <- character()
      }

      ig_media_id_to_process_v <- current_type_ig_media_id[!(current_type_ig_media_id %in% previous_ig_media_id_v)]

      all_new_df <- purrr::map(
        .progress = stringr::str_c(
          "Now processing media of type ",
          sQuote(current_media_type)
        ),
        .x = ig_media_id_to_process_v,
        .f = function(current_ig_media_id) {
          current_media_df <- cc_api_get_instagram_media_insights(
            ig_media_id = current_ig_media_id,
            media_type = current_media_type,
            api_version = "v18.0",
            token = token
          )

          if (cache == TRUE) {
            DBI::dbAppendTable(
              conn = db,
              name = current_table,
              value = current_media_df
            )
          }

          current_media_df
        }
      ) |>
        purrr::list_rbind()

      if (cache == TRUE) {
        output_df <- dplyr::bind_rows(
          previous_ig_media_df |> dplyr::collect(),
          all_new_df
        ) |>
          tibble::as_tibble()
      } else {
        output_df <- all_new_df |>
          dplyr::mutate(ig_media_type = current_media_type)
      }
      output_df |>
        dplyr::mutate(ig_media_type = current_media_type)
    }
  ) |>
    purrr::list_rbind()

  if (cache == TRUE) {
    DBI::dbDisconnect(db)
  }

  dplyr::bind_rows(
    cc_empty_instagram_media_insights |>
      purrr::list_rbind(),
    all_types_output_df
  ) |>
    dplyr::relocate(ig_media_id, ig_media_type) |>
    dplyr::relocate(timestamp_retrieved, .after = last_col()) |>
    dplyr::group_by(ig_media_id) |>
    dplyr::slice_max(order_by = timestamp_retrieved, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()
}


#' Get information about a single media directly from the API. Mostly used
#' internally.
#'
#' See the official documentation for reference:
#' \url{https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights}
#'
#' @param ig_media_id Instagram media identifier, must be a vector of length 1.
#'   A list of identifiers for your account can be retrieved with
#'   `cc_get_instagram_media_id()`.
#' @param metrics Metrics to be retrieved. Consider that depending on the media
#'   type, different media types are effectively available. Requesting the wrong
#'   metrics will cause an error. Defaults to NULL. If left to NULL, metrics will be chosen based on the media type. See the official documentation for reference:
#'   \url{https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights}
#' @param media_type Media type. Valid values include "IMAGE", "VIDEO", "REELS", and
#'   "CAROUSEL_ALBUM". Defaults to NULL. If not given, it will be retrieved with
#'   `cc_get_instagram_media`. Ignored if `metrics` explicitly given.
#'
#' @inheritParams cc_get_instagram_media
#'
#' @return
#' @export
#'
#' @examples
cc_api_get_instagram_media_insights <- function(ig_media_id,
                                                metrics = NULL,
                                                media_type = NULL,
                                                api_version = "v18.0",
                                                ig_user_id = NULL,
                                                token = NULL) {
  if (is.null(token)) {
    fb_user_token <- cc_get_settings(fb_user_token = token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(token)
  }

  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  if (is.null(metrics)) {
    if (is.null(media_type)) {
      current_media_df <- cc_get_instagram_media(
        ig_media_id = ig_media_id,
        fields = "media_type",
        api_version = api_version,
        ig_user_id = ig_user_id,
        token = token
      )
      media_type <- current_media_df |>
        dplyr::pull(media_type)
    }

    if (stringr::str_to_lower(media_type) == "reels") {
      metrics <- cc_valid_metrics_ig_media_insights$reels
    } else if (stringr::str_to_lower(media_type) == "image" | stringr::str_to_lower(media_type) == "video") {
      metrics <- cc_valid_metrics_ig_media_insights$photo_video
    } else if (stringr::str_to_lower(media_type) == "carousel_album") {
      metrics <- cc_valid_metrics_ig_media_insights$carousel
    } else if (stringr::str_to_lower(media_type) == "reels") {
      metrics <- cc_valid_metrics_ig_media_insights$reels
    } else if (stringr::str_to_lower(media_type) == "story") {
      metrics <- cc_valid_metrics_ig_media_insights$story
    } else {
      cli::cli_abort(message = "Unkown {.var media_type}. Provide {.var metrics} explicitly.")
    }
  }

  metrics_v <- stringr::str_c(metrics, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(ig_media_id) |>
    httr2::req_url_path_append("insights") |>
    httr2::req_url_query(
      metric = metrics_v,
      access_token = fb_user_token
    )

  req <- httr2::req_perform(req = api_request)

  current_l <- httr2::resp_body_json(req)

  output_df <- purrr::map(.x = current_l$data, .f = function(x) {
    tibble::enframe(
      x = x |> purrr::pluck("values", 1, "value") |> as.numeric(),
      name = NULL,
      value = x |> purrr::pluck("name") |> as.character()
    )
  }) |>
    purrr::list_cbind() |>
    dplyr::mutate(ig_media_id = ig_media_id) |>
    dplyr::relocate(ig_media_id) |>
    dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z"))

  output_df
}
