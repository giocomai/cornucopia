#' Retrieve information about a user through Instagram's business discovery
#'
#' This function allows you to retrieve basic information about an Instagram account you are not associated with, as long as they are a business account.
#'
#' [More details about Business Discovery and relevant permissions](https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/business_discovery/).
#'
#' @inheritParams cc_get_instagram_bd_user_media
#'
#' @returns
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive) {
#'   # e.g. to retrieve information about the Instagram account of the United Nations
#'   cc_get_instagram_bd_user(ig_username = "unitednations")
#' }
#' }
cc_get_instagram_bd_user <- function(ig_username,
                                     fields = c(
                                       "id",
                                       "ig_id",
                                       "username",
                                       "name",
                                       "biography",
                                       "website",
                                       "followers_count",
                                       "follows_count",
                                       "media_count",
                                       "profile_picture_url"
                                     ),
                                     api_version = "v21.0",
                                     ig_user_id = NULL,
                                     fb_user_token = NULL) {
  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  fields_v <- stringr::str_c(fields, collapse = ",")

  purrr::map(
    .progress = TRUE,
    .x = ig_username,
    .f = \(current_ig_username) {
      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(ig_user_id) |>
        httr2::req_url_query(
          fields = stringr::str_c(
            "business_discovery.username(",
            current_ig_username,
            "){",
            fields_v,
            "}"
          ),
          access_token = fb_user_token
        )

      response <- api_request |>
        httr2::req_error(is_error = \(resp) FALSE) |>
        httr2::req_perform()

      response_l <- response |>
        httr2::resp_body_json()

      if (is.null(response_l[["error"]][["message"]]) == FALSE) {
        cli::cli_abort(response_l[["error"]][["message"]])
      }

      tibble::as_tibble(response_l[["business_discovery"]])
    }
  ) |>
    purrr::list_rbind()
}


#' Retrieve identifier of Instagram user
#'
#' Mostly used internally for consistent storing and caching.
#'
#' @param ig_username Instagram username of an Instagram business user.
#'
#' @returns
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive) {
#'   # e.g. to retrieve information about the Instagram account of the United Nations
#'   cc_get_instagram_bd_user_basic(ig_username = "unitednations")
#' }
#' }
cc_get_instagram_bd_user_basic <- function(ig_username,
                                           cache = TRUE,
                                           api_version = "v21.0",
                                           ig_user_id = NULL,
                                           fb_user_token = NULL) {
  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
    }
    fs::dir_create("cornucopia_db")

    db <- DBI::dbConnect(
      drv = RSQLite::SQLite(),
      fs::path(
        "cornucopia_db",
        fs::path_ext_set(stringr::str_c("ig_bd_users"), ".sqlite") |>
          fs::path_sanitize()
      )
    )

    current_table <- "ig_bd_users"

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = cc_empty_instagram_ig_bd_users_df |> tibble::as_tibble()
      )
    }

    previous_ig_bd_users_df <- DBI::dbReadTable(
      conn = db,
      name = current_table
    ) |>
      dplyr::filter(username %in% ig_username) |>
      dplyr::collect()
  } else {
    previous_ig_bd_users_df <- cc_empty_instagram_ig_bd_users_df
  }

  ig_username_to_process <- ig_username[!ig_username %in% previous_ig_bd_users_df[["username"]]]

  if (length(ig_username_to_process) == 0) {
    return(previous_ig_bd_users_df)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  fields_v <- stringr::str_flatten(colnames(cc_empty_instagram_ig_bd_users_df), collapse = ",")

  output_df <- purrr::map(
    .progress = TRUE,
    .x = ig_username,
    .f = \(current_ig_username) {
      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(ig_user_id) |>
        httr2::req_url_query(
          fields = stringr::str_c(
            "business_discovery.username(",
            current_ig_username,
            "){",
            fields_v,
            "}"
          ),
          access_token = fb_user_token
        )

      response <- api_request |>
        httr2::req_error(is_error = \(resp) FALSE) |>
        httr2::req_perform()

      response_l <- response |>
        httr2::resp_body_json()

      if (is.null(response_l[["error"]][["message"]]) == FALSE) {
        cli::cli_abort(response_l[["error"]][["message"]])
      }

      bd_response_df <- tibble::as_tibble(response_l[["business_discovery"]]) |>
        dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

      if (cache == TRUE) {
        DBI::dbAppendTable(
          conn = db,
          name = current_table,
          value = bd_response_df
        )
      }
      bd_response_df
    }
  ) |>
    purrr::list_rbind()

  if (cache == TRUE) {
    output_df <- tibble::tibble(username = ig_username) |>
      dplyr::left_join(
        y = dplyr::bind_rows(
          previous_ig_bd_users_df,
          output_df
        ),
        by = "username"
      )
  }

  output_df
}
