#' Get details about a given Instagram post based on its ig_media_id
#'
#' It retrieves the requested fields from the APIs and introduces a few
#' adjustments:
#'
#' - it always include the media id, in a column named `ig_media_id`
#' - if the field `owner` is included, it outputs the result as a character vector (if more than one owner, separated by ;)
#' - it adds a `timestamp_retrieved` column, with ISO 8601-formatted creation date in UTC
#' - it ensures that the output always included all requested fields, if they are valid; e.g. `is_shared_to_feed` and `media_url` may be omitted by the API (see documentation) but this function always includes the relevant column (and returns a NA value if no value is given)
#' - all valid fields for the given API endpoint are always requested and cached locally; only requested fields are effectively returned (but `ig_media_id` and `timestamp_retrieved` are always included as first and last column)
#'
#' For details, see:
#' https://developers.facebook.com/docs/instagram-api/reference/ig-media
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
#' cc_get_instagram_media()
#' }
cc_get_instagram_media <- function(
  ig_media_id = NULL,
  fields = cc_valid_fields_instagram_media_v,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ig_user_id = NULL,
  update = TRUE,
  cache = TRUE,
  fb_user_token = NULL
) {
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
      meta_api_version = meta_api_version,
      fb_user_token = fb_user_token,
      cache = cache
    ) |>
      dplyr::pull(ig_media_id)
  }

  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort(
        "Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE."
      )
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

    current_table <- "ig_media"

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = cc_empty_instagram_media_df
      )
    }

    ig_media_all_requested_v <- ig_media_id

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
        dplyr::slice_max(
          order_by = timestamp_retrieved,
          n = 1,
          with_ties = FALSE
        ) |>
        dplyr::ungroup()

      if (update == TRUE) {
        update_df <- cc_check_instagram_media_update(
          ig_media_id = unique(previous_ig_media_df$ig_media_id),
          ig_user_id = ig_user_id,
          insights = FALSE,
          fb_user_token = fb_user_token
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
    previous_ig_media_id_v <- character()
  }

  ig_media_id_to_process_v <- ig_media_id[
    !(ig_media_id %in% previous_ig_media_id_v)
  ]

  all_new_df <- purrr::map(
    .progress = TRUE,
    .x = ig_media_id_to_process_v,
    .f = function(current_ig_media_id) {
      current_media_df <- cc_api_get_instagram_media(
        ig_media_id = current_ig_media_id,
        fields = fields,
        meta_api_version = meta_api_version,
        fb_user_token = fb_user_token
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
      tibble::as_tibble() |>
      dplyr::group_by(ig_media_id) |>
      dplyr::slice_max(
        order_by = timestamp_retrieved,
        n = 1,
        with_ties = FALSE
      ) |>
      dplyr::ungroup()

    DBI::dbDisconnect(db)
  } else {
    output_df <- all_new_df
  }

  output_df
}


#' Get information about a single media directly from the API. Mostly used
#' internally.
#'
#' @param ig_media_id Instagram media identifier, must be a vector of length 1.
#'   A list of identifiers for your account can be retrieved with
#'   `cc_get_instagram_media_id()`.
#' @inheritParams cc_get_instagram_media
#'
#' @return
#' @export
#'
#' @examples
cc_api_get_instagram_media <- function(
  ig_media_id,
  fields = cornucopia::cc_valid_fields_instagram_media_v,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_user_token = NULL
) {
  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  if (!"id" %in% fields) {
    fields <- c("id", fields)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    meta_api_version
  )

  fields_v <- stringr::str_flatten(fields, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(ig_media_id) |>
    httr2::req_url_query(
      fields = fields_v,
      access_token = fb_user_token
    )

  req <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  current_l <- httr2::resp_body_json(req)

  if (is.null(current_l[["error"]][["message"]]) == FALSE) {
    cli::cli_abort(current_l[["error"]][["message"]])
  }

  output_df <- tibble::as_tibble(current_l) |>
    dplyr::rename(ig_media_id = "id") |>
    dplyr::mutate(
      timestamp_retrieved = strftime(
        as.POSIXlt(Sys.time(), "UTC"),
        "%Y-%m-%dT%H:%M:%S%z"
      )
    )

  if ("owner" %in% colnames(output_df)) {
    output_df <- output_df |>
      dplyr::mutate(
        owner = as.character(unlist(stringr::str_c(
          .data[["owner"]],
          collapse = ";"
        )))
      )
  }

  output_df <- dplyr::bind_rows(
    cornucopia::cc_empty_instagram_media_df,
    output_df
  )

  fields_filter <- fields[fields != "id"]

  final_output_df <- output_df[c(
    "ig_media_id",
    fields_filter,
    "timestamp_retrieved"
  )]

  final_output_df
}
