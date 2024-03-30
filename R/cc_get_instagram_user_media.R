#' Retrieve information about other users through `business_discovery`
#'
#' Consider that only information about posts of creative or business users may be available.
#' Given restrictions on the rate limit, you are likely to hit rate limits quite soon.
#' Wait one hour and try again.
#'
#' @param ig_username A user name of an Instagram user.
#' @param media_fields Defaults to all fields publicly available through `business_discovery`.
#' @inheritParams cc_get_fb_page_posts
#'
#' @return
#' @export
#'
#' @examples
cc_get_instagram_user_media <- function(ig_username,
                                        media_fields = c("like_count", "comments_count", "caption", "media_product_type", "media_type", "media_url", "permalink", "thumbnail_url", "timestamp", "username"),
                                        max_pages = NULL,
                                        api_version = "v18.0",
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

  users_posts_df <- purrr::map(
    .x = ig_username,
    .progress = stringr::str_c("Retrieving user posts"),
    .f = function(current_user) {
      out <- vector("list", max_pages %||% 1000)
      posts_l <- vector("list", max_pages %||% 1000)

      i <- 1L

      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(ig_user_id) |>
        httr2::req_url_query(
          fields = stringr::str_c(
            "business_discovery.username(",
            current_user,
            "){media{",
            stringr::str_flatten(media_fields, collapse = ","),
            "}}"
          ),
          access_token = fb_user_token
        )

      repeat({
        # cli::cli_progress_update(inc = 25)

        req <- api_request |>
          httr2::req_error(is_error = \(resp) FALSE) |>
          httr2::req_perform() |>
          httr2::resp_body_json()

        if (is.null(out[[i]][["error"]][["message"]]) == FALSE) {
          cli::cli_warn(out[[i]][["error"]][["message"]])
          cli::cli_inform(c(x = "Not all posts have been processed."))

          break
        }

        out[[i]] <- req

        if (!is.null(max_pages) && i == max_pages) {
          break
        }

        if (purrr::pluck_exists(out[[i]], "business_discovery", "media", "paging", "cursors", "after") == TRUE) {
          after_string <- purrr::pluck(out[[i]], "business_discovery", "media", "paging", "cursors", "after")

          api_request <- httr2::request(base_url = base_url) |>
            httr2::req_url_path_append(ig_user_id) |>
            httr2::req_url_query(
              fields = stringr::str_c(
                "business_discovery.username(",
                current_user,
                "){media.after(",
                after_string,
                "){",
                stringr::str_flatten(media_fields, collapse = ","),
                "}}"
              ),
              access_token = fb_user_token
            )
        } else {
          break
        }

        i <- i + 1L
        if (i > length(out)) {
          length(out) <- length(out) * 2L
        }
      })

      post_details_df <- purrr::map(
        .x = out,
        .f = function(current_set) {
          current_set_l <- current_set |>
            purrr::pluck("business_discovery", "media", "data")

          purrr::map(current_set_l,
            .f = function(current_set) {
              current_set |>
                tibble::as_tibble()
            }
          ) |>
            purrr::list_rbind()
        }
      )


      if (purrr::pluck_exists(out[[max(c(i - 1, 1))]], "business_discovery", "media", "paging", "cursors", "after") == TRUE) {
        current_set_l <- out[[max(c(i - 1, 1))]] |>
          purrr::pluck("business_discovery", "media", "data")

        fs::dir_create("cornucopia_db")

        db <- DBI::dbConnect(
          drv = RSQLite::SQLite(),
          fs::path(
            "cornucopia_db",
            fs::path_ext_set(stringr::str_c("ig_bd_", ig_user_id), ".sqlite") |>
              fs::path_sanitize()
          )
        )

        DBI::dbWriteTable(
          conn = db,
          name = "ig_bd",
          value = tibble::tibble(
            ig_username = ig_username,
            after = purrr::pluck(out[[max(c(i - 1, 1))]], "business_discovery", "media", "paging", "cursors", "after"),
            oldest_timestamp = current_set_l[[min(length(current_set_l), 25)]][["timestamp"]]
          ),
          append = TRUE
        )

        DBI::dbDisconnect(db)
      }

      post_details_df |>
        purrr::list_rbind() |>
        dplyr::relocate(id, username, timestamp, permalink)
    }
  ) |>
    purrr::list_rbind()
}
