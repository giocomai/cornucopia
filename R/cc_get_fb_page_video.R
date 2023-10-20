#' Get Facebook page video id and basic information that can be stored as strings
#'
#' See: https://developers.facebook.com/docs/video-api/guides/get-videos/
#'
#' @param api_version
#' @param max_pages
#' @param cache
#' @param fb_page_id
#' @param fb_page_token
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_page_video <- function(api_version = "v18.0",
                                 max_pages = NULL,
                                 cache = TRUE,
                                 fb_page_id = NULL,
                                 fb_page_token = NULL) {
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


  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
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

    current_table <- "fb_page_video"

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = cc_empty_fb_page_video_df
      )
    }

    previous_fb_video_df <- DBI::dbReadTable(
      conn = db,
      name = current_table
    ) |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
      tibble::as_tibble()
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_page_id) |>
    httr2::req_url_path_append("videos") |>
    httr2::req_url_query(
      access_token = fb_page_token,
      fields = stringr::str_flatten(names(cc_empty_fb_page_video_df), collapse = ",")
    )


  # https://github.com/r-lib/httr2/issues/8#issuecomment-866221516

  out <- vector("list", max_pages %||% 1000)

  i <- 1L
  cli::cli_progress_bar(name = "Retrieving Facebook page videos:")

  repeat({
    cli::cli_progress_update(inc = 25)

    out[[i]] <- httr2::req_perform(api_request) |>
      httr2::resp_body_json()

    if (!is.null(max_pages) && i == max_pages) {
      break
    }

    new_video_df <- purrr::map(
      .x = purrr::pluck(out[[i]], "data"),
      .f = function(y) {
        tibble::as_tibble(y)
      }
    ) |>
      purrr::list_rbind() |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

    if (cache == TRUE) {
      really_new_video_df <- new_video_df |>
        dplyr::anti_join(
          y = previous_fb_video_df,
          by = "id"
        )
    } else {
      really_new_video_df <- new_video_df
    }

    if (nrow(really_new_video_df) == 0) {
      break
    } else {
      if (cache == TRUE) {
        DBI::dbAppendTable(
          conn = db,
          name = current_table,
          value = really_new_video_df
        )
      }
    }

    if (purrr::pluck_exists(out[[i]], "paging", "next") == TRUE) {
      api_request <- purrr::pluck(out[[i]], "paging", "next") |>
        httr2::request()
    } else {
      break
    }

    i <- i + 1L
    if (i > length(out)) {
      length(out) <- length(out) * 2L
    }
  })

  cli::cli_process_done()

  video_df <- purrr::map(
    .x = out,
    .f = function(x) {
      purrr::map(
        .x = purrr::pluck(x, "data"),
        .f = function(y) {
          tibble::as_tibble(y) |>
            dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
        }
      ) |>
        purrr::list_rbind()
    }
  ) |>
    purrr::list_rbind()

  if (cache == TRUE) {
    output_df <- dplyr::bind_rows(
      previous_fb_video_df,
      video_df
    ) |>
      tibble::as_tibble() |>
      dplyr::distinct(id, .keep_all = TRUE) |>
      dplyr::arrange(created_time)

    DBI::dbDisconnect(db)
  } else {
    output_df <- video_df
  }

  output_df
}
