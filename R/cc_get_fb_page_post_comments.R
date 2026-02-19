#' Get Facebook page posts comments
#'
#' For reference, see the
#' \href{https://developers.facebook.com/docs/graph-api/reference/page-post/comments}{official
#' documentation}.
#'
#' @param fb_post_id Facebook post identifier, must be a vector, or a data frame
#'   with an `id` column with Facebook post identifiers.
#'   Facebook page post identifiers can be retrieved with
#'   [cc_get_fb_page_posts()].
#' @inheritParams cc_api_get_fb_page_post_comments
#'
#' @return A data frame with comments.
#' @export
#'
#' @examples
cc_get_fb_page_post_comments <- function(
  fb_post_id = NULL,
  cache = TRUE,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
) {
  if (is.null(fb_page_token)) {
    fb_page_token <- cc_get_settings(fb_page_token = fb_page_token) |>
      purrr::pluck("fb_page_token")
  } else {
    fb_page_token <- as.character(fb_page_token)
  }

  if (is.null(fb_page_id)) {
    fb_page_id <- cc_get_settings(fb_page_id = fb_page_id) |>
      purrr::pluck("fb_page_id")
  } else {
    fb_page_id <- as.character(fb_page_id)
  }

  if (is.null(fb_post_id)) {
    fb_post_id <- cc_get_fb_page_posts(
      meta_api_version = meta_api_version,
      max_pages = NULL,
      fields = names(cc_empty_fb_page_post_df),
      cache = cache,
      fb_page_id = fb_page_id,
      fb_page_token = fb_page_token
    ) |>
      dplyr::pull(id)
  }

  if (is.data.frame(fb_post_id)) {
    if ("id" %in% colnames(fb_post_id)) {
      fb_post_id <- fb_post_id[["id"]]
    } else {
      cli::cli_abort(
        message = "{.var fb_post_id} must be a vector, or a data frame with a column named {.val id}"
      )
    }
  }

  if (cache) {
    if (!requireNamespace("RSQLite", quietly = TRUE)) {
      cli::cli_abort(
        "Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE."
      )
    }

    fs::dir_create("cornucopia_db")

    db <- DBI::dbConnect(
      drv = RSQLite::SQLite(),
      fs::path(
        "cornucopia_db",
        fs::path_ext_set(stringr::str_c("fb_page_", fb_page_id), ".sqlite") |>
          fs::path_sanitize()
      )
    )

    current_table <- "fb_page_post_comments"

    if (!DBI::dbExistsTable(conn = db, name = current_table)) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = tibble::as_tibble(cc_empty_fb_page_post_comments_df)
      )
      previous_fb_post_comments_df <- tibble::as_tibble(
        cc_empty_fb_page_post_comments_df
      )
    } else {
      fb_post_id_to_keep_v <- fb_post_id
      previous_fb_post_comments_df <- DBI::dbReadTable(
        conn = db,
        name = current_table
      ) |>
        dplyr::filter(.data[["fb_post_id"]] %in% fb_post_id_to_keep_v) |>
        dplyr::collect() |>
        tibble::as_tibble()
    }
  } else {
    previous_fb_post_comments_df <- tibble::as_tibble(
      cc_empty_fb_page_post_comments_df
    )

    db <- NULL
  }

  fb_post_id <- fb_post_id[
    !(fb_post_id %in% previous_fb_post_comments_df[["fb_post_id"]])
  ]

  new_comments_df <- purrr::map(
    .x = as.character(fb_post_id),
    .progress = TRUE,
    .f = function(x) {
      cc_api_get_fb_page_post_comments(
        fb_post_id = x,
        cache = cache,
        cache_connection = db,
        update = update,
        meta_api_version = meta_api_version,
        fb_page_id = fb_page_id,
        fb_page_token = fb_page_token
      )
    }
  ) |>
    purrr::list_rbind()

  DBI::dbDisconnect(db)

  dplyr::bind_rows(previous_fb_post_comments_df, new_comments_df)
}


#' Retrieve comments from a single Facebook Page post. Mostly used internally.
#'
#' For reference, see the
#' \href{https://developers.facebook.com/docs/graph-api/reference/page-post/comments}{official
#' documentation}.
#'
#' @param fb_post_id Facebook post identifier, must be a vector of length 1.
#'   A list of identifiers for a given Facebook page can be retrieved with
#'   [cc_get_fb_page_posts()].
#'
#'
#' @inheritParams cc_get_fb_page_posts
#'
#' @return A data frame with comments for a given post.
#' @export
#'
#' @examples
cc_api_get_fb_page_post_comments <- function(
  fb_post_id,
  cache = TRUE,
  cache_connection = NULL,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
) {
  if (is.null(fb_page_token)) {
    fb_page_token <- cc_get_settings(fb_page_token = fb_page_token) |>
      purrr::pluck("fb_page_token")
  } else {
    fb_page_token <- as.character(fb_page_token)
  }

  if (is.null(fb_page_id)) {
    fb_page_id <- cc_get_settings(fb_page_id = fb_page_id) |>
      purrr::pluck("fb_page_id")
  } else {
    fb_page_id <- as.character(fb_page_id)
  }

  if (cache) {
    if (!requireNamespace("RSQLite", quietly = TRUE)) {
      cli::cli_abort(
        "Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE."
      )
    }

    if (!is.null(cache_connection) & !is.list(cache_connection)) {
      if (!DBI::dbIsValid(cache_connection)) {
        db <- NULL
      } else {
        db <- cache_connection
      }
    }

    current_table <- "fb_page_post_comments"

    if (is.null(db)) {
      fs::dir_create("cornucopia_db")

      db <- DBI::dbConnect(
        drv = RSQLite::SQLite(),
        fs::path(
          "cornucopia_db",
          fs::path_ext_set(stringr::str_c("fb_page_", fb_page_id), ".sqlite") |>
            fs::path_sanitize()
        )
      )
    }
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    meta_api_version
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_post_id) |>
    httr2::req_url_path_append("comments") |>
    httr2::req_url_query(
      access_token = fb_page_token
    )

  response_l <- api_request |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (!is.null(response_l[["error"]][["message"]])) {
    cli::cli_alert_warning(response_l[["error"]][["message"]])
    return(NULL)
  }

  if (length(response_l[["data"]]) == 0) {
    output_df <- tibble::tibble(
      created_time = NA_character_,
      message = NA_character_,
      comment_id = NA_character_,
      fb_post_id = fb_post_id,
      timestamp_retrieved = strftime(
        as.POSIXlt(Sys.time(), "UTC"),
        "%Y-%m-%dT%H:%M:%S%z"
      )
    )
  } else {
    output_df <- purrr::map(
      .x = response_l[["data"]],
      .f = function(current_element_l) {
        current_element_l_to_df <- current_element_l
        current_element_l_to_df[["from"]] <- NULL

        current_element_df <- current_element_l_to_df |>
          tibble::as_tibble()

        if (is.null(current_element_l[["from"]])) {
          current_element_from_df <- tibble::tibble(
            from_name = NA_character_,
            from_id = NA_character_
          )
        } else {
          current_element_from_df <- current_element_l[["from"]] |>
            tibble::as_tibble() |>
            dplyr::rename_with(.fn = \(x) {
              stringr::str_c("from_", x)
            })
        }

        current_output_df <- current_element_df |>
          dplyr::bind_cols(current_element_from_df)

        current_output_df
      }
    ) |>
      purrr::list_rbind() |>
      dplyr::mutate(
        fb_post_id = as.character(fb_post_id)
      ) |>
      dplyr::rename(comment_id = "id") |>
      dplyr::mutate(
        timestamp_retrieved = strftime(
          as.POSIXlt(Sys.time(), "UTC"),
          "%Y-%m-%dT%H:%M:%S%z"
        )
      )
  }

  if (cache) {
    DBI::dbAppendTable(
      conn = db,
      name = current_table,
      value = output_df
    )
  }

  output_df
}
