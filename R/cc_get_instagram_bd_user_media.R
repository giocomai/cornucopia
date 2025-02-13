#' Retrieve information about other users through `business_discovery`
#'
#' Consider that only information about posts of creative or business users may be available.
#' Given restrictions on the rate limit, you are likely to hit rate limits quite soon.
#' Wait one hour and try again.
#'
#' For details about rate limits, see [this section of the documentation](https://developers.facebook.com/docs/graph-api/overview/rate-limiting).
#'
#' [More details about Business Discovery and relevant permissions](https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/business_discovery/).
#'
#' In brief, necessary:
#'
#' - `instagram_basic`
#' - `instagram_manage_insights`
#' - `pages_read_engagement` or `pages_show_list`
#'
#' If the token is from a User whose Page role was granted via the Business Manager, one of the following permissions is also required:
#'
#' - `ads_management`
#' - `pages_read_engagement`
#' - `business_management`
#'
#' @param ig_username A user name of an Instagram user.
#' @param fields Defaults to all fields publicly available through
#'   `business_discovery`. See [the documentation](https://developers.facebook.com/docs/instagram-platform/reference/instagram-media)
#'   for other fields that may be available.
#' @param wait Defaults to zero. Time in seconds before each request to the API.
#'   If you make a very small number of queries, you can leave it to zero. If
#'   you make a even just a few dozens query, you'll hit API limits unless you
#'   set a wait time. Setting this to 300 (5 minutes) should slow things down
#'   just enough (but yes, this means you'll get 25 posts every five minutes, no
#'   more and no less).
#' @param limit Defaults to 80, meaning 80%. It means that when either of the
#'   three values determining rate limiting reaches at least 80%, the function
#'   returns what it has collected so far. Set to NULL to ignore. For details,
#'   see [the official documentation](https://developers.facebook.com/docs/graph-api/overview/rate-limiting/).
#' @inheritParams cc_get_fb_page_posts
#'
#' @return
#' @export
#'
#' @examples
cc_get_instagram_bd_user_media <- function(ig_username,
                                           fields = c(
                                             "username",
                                             "timestamp",
                                             "like_count",
                                             "comments_count",
                                             "caption",
                                             "media_product_type",
                                             "media_type",
                                             "media_url",
                                             "thumbnail_url",
                                             "permalink"
                                           ),
                                           max_pages = NULL,
                                           wait = 0,
                                           limit = 80,
                                           update = TRUE,
                                           cache = TRUE,
                                           api_version = "v22.0",
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

  fields_filter <- fields[fields != "id"]

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  users_posts_df <- purrr::map(
    .x = ig_username,
    .progress = stringr::str_c("Retrieving user posts"),
    .f = function(current_user) {
      bd_user_basic_df <- cc_get_instagram_bd_user_basic(
        ig_username = current_user,
        cache = cache,
        api_version = api_version,
        ig_user_id = ig_user_id,
        fb_user_token = fb_user_token
      )

      if (cache) {
        current_user_id <- bd_user_basic_df[["id"]]

        fs::dir_create("cornucopia_db")

        db <- DBI::dbConnect(
          drv = RSQLite::SQLite(),
          fs::path(
            "cornucopia_db",
            fs::path_ext_set(stringr::str_c("ig_bd_", current_user_id), ".sqlite") |>
              fs::path_sanitize()
          )
        )

        if (DBI::dbExistsTable(conn = db, name = "media")) {
          # TODO
          # check previous data
        } else {
          # TODO
          # create empty table
        }
      }

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
            stringr::str_flatten(fields, collapse = ","),
            "}}"
          ),
          access_token = fb_user_token
        )

      cli::cli_progress_bar(name = cli::cli_text("Retrieving posts for user {.val {current_user}}:"))

      repeat({
        cli::cli_progress_update(inc = 25)

        resp <- api_request |>
          httr2::req_error(is_error = \(resp) FALSE) |>
          httr2::req_perform()

        if (is.null(limit) == FALSE) {
          limits_l <- resp$headers$`x-app-usage` |>
            jsonlite::parse_json(simplifyVector = TRUE)
          if (sum(limits_l > limit) >= 1) {
            over_limits <- limits_l[which.max(unlist(limits_l))]

            cli::cli_alert_warning("Rate limit has reached threshold: {.var {names(over_limits)}} is now at {.val {over_limits}%}")
            cli::cli_alert_success("Returning the {.val {i}} pages retrieved so far, presumably corresponding to {.val {i*25}} posts.")
            cli::cli_alert_info("Consider waiting for an hour for limits to reset, and set {.var wait} to 300 before retrying.")

            break
          }
        }

        req <- resp |>
          httr2::resp_body_json()

        if (is.null(req[["error"]][["message"]]) == FALSE) {
          cli::cli_alert_danger(req[["error"]][["message"]])
          cli::cli_alert_success("Returning the {.val {i}} pages retrieved so far, presumably corresponding to {.val {i*25}} posts.")
          cli::cli_alert_info("Consider waiting for an hour for limits to reset, and set {.var wait} to 300 before retrying.")
          break
        }

        current_set_l <- req |>
          purrr::pluck("business_discovery", "media", "data")

        current_post_set_details_df <- purrr::map(current_set_l,
          .f = function(current_set) {
            current_set |>
              tibble::as_tibble()
          }
        ) |>
          purrr::list_rbind() |>
          dplyr::rename(ig_media_id = id) |>
          dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z")) |>
          dplyr::relocate(ig_media_id)

        if (!"thumbnail_url" %in% colnames(current_post_set_details_df)) {
          current_post_set_details_df <- current_post_set_details_df |>
            dplyr::mutate(thumbnail_url = NA_character_)
        }

        output_df <- current_post_set_details_df[c("ig_media_id", fields_filter, "timestamp_retrieved")]

        out[[i]] <- output_df

        if (purrr::pluck_exists(req, "business_discovery", "media", "paging", "cursors", "after") == TRUE) {
          after_string <- purrr::pluck(req, "business_discovery", "media", "paging", "cursors", "after")

          api_request <- httr2::request(base_url = base_url) |>
            httr2::req_url_path_append(ig_user_id) |>
            httr2::req_url_query(
              fields = stringr::str_c(
                "business_discovery.username(",
                current_user,
                "){media.after(",
                after_string,
                "){",
                stringr::str_flatten(fields, collapse = ","),
                "}}"
              ),
              access_token = fb_user_token
            )

          readr::write_lines(
            x = after_string,
            file = fs::path(
              "cornucopia_db",
              fs::path_ext_set(stringr::str_c("bd_user_media_", bd_user_basic_df$id), ".txt") |>
                fs::path_sanitize()
            )
          )
        } else {
          break
        }

        if (!is.null(max_pages) && i == max_pages) {
          break
        }

        i <- i + 1L
        if (i > length(out)) {
          length(out) <- length(out) * 2L
        }

        Sys.sleep(time = wait)
      })

      out |>
        purrr::list_rbind()
    }
  ) |>
    purrr::list_rbind()


  # if (purrr::pluck_exists(out[[max(c(i - 1, 1))]], "business_discovery", "media", "paging", "cursors", "after") == TRUE) {
  #   current_set_l <- out[[max(c(i - 1, 1))]] |>
  #     purrr::pluck("business_discovery", "media", "data")
  #
  #
  #   DBI::dbWriteTable(
  #     conn = db,
  #     name = "ig_bd",
  #     value = tibble::tibble(
  #       ig_username = ig_username,
  #       after = purrr::pluck(out[[max(c(i - 1, 1))]], "business_discovery", "media", "paging", "cursors", "after"),
  #       oldest_timestamp = current_set_l[[min(length(current_set_l), 25)]][["timestamp"]]
  #     ),
  #     append = TRUE
  #   )
  #
  #   DBI::dbDisconnect(db)
  # }

  users_posts_df
}
