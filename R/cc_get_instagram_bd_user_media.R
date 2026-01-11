#' Retrieve information about other users through `business_discovery`
#'
#' Consider that only information about posts of creative of business users may be available.
#' Given restrictions on the rate limit, you are likely to hit rate limits quite soon.
#' Wait one hour and try again. See `wait` and `limit` parameters for more options.
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
#'   `business_discovery`. See [the
#'   documentation](https://developers.facebook.com/docs/instagram-platform/reference/instagram-media)
#'   for other fields that may be available.
#' @param mode Defaults to "update", available options include "full" and
#'   "only_cached". If set to "full", and some media have been previously
#'   retrieved, it tries to continue from the previous request as long as all
#'   available media have been retrieved. If set to "update", it retrieves the
#'   latest media, even if previously retrieved, to update relevant fields.
#'   "only_cached" retrieves only cached data; for each media, it outputs only
#'   the most recently retrived data.
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
#' @return A data frame with the selected fields as columns, and a row for each post of the selected Instagram account.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_instagram_bd_user_media(
#'   ig_username = "unitednations",
#'   max_pages = 3
#' )
#'
#' # the following retrieves older posts, starting from where it left off
#' cc_get_instagram_bd_user_media(
#'   ig_username = "unitednations",
#'   mode = "full",
#'   max_pages = 3
#' )
#' }
cc_get_instagram_bd_user_media <- function(
  ig_username,
  mode = c("update", "full", "only_cached"),
  fields = c(
    "username",
    "timestamp",
    "like_count",
    "view_count",
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
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ig_user_id = NULL,
  fb_user_token = NULL
) {
  if (!(mode[[1]] %in% c("update", "full", "only_cached"))) {
    cli::cli_abort("Invalid {.var mode}. Check documentation.")
  }

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
    meta_api_version
  )

  users_posts_df <- purrr::map(
    .x = ig_username,
    .progress = stringr::str_c("Retrieving user posts"),
    .f = function(current_user) {
      bd_user_basic_df <- cc_get_instagram_bd_user_basic(
        ig_username = current_user,
        cache = cache,
        meta_api_version = meta_api_version,
        ig_user_id = ig_user_id,
        fb_user_token = fb_user_token
      )

      after_string_path <- fs::path(
        "cornucopia_db",
        fs::path_ext_set(
          stringr::str_c("bd_user_media_", bd_user_basic_df$id),
          ".txt"
        ) |>
          fs::path_sanitize()
      )

      if (cache) {
        current_user_id <- bd_user_basic_df[["id"]]

        fs::dir_create("cornucopia_db")

        db <- DBI::dbConnect(
          drv = RSQLite::SQLite(),
          fs::path(
            "cornucopia_db",
            fs::path_ext_set(
              stringr::str_c("ig_bd_", current_user_id),
              ".sqlite"
            ) |>
              fs::path_sanitize()
          )
        )

        if (DBI::dbExistsTable(conn = db, name = "ig_bd_media")) {
          # TODO
          # check previous data

          previous_ig_bd_media_df <- DBI::dbReadTable(
            conn = db,
            name = "ig_bd_media"
          ) |>
            dplyr::arrange(dplyr::desc(timestamp_retrieved)) |>
            dplyr::distinct(ig_media_id, .keep_all = TRUE) |>
            dplyr::arrange(dplyr::desc(timestamp)) |>
            dplyr::collect() |>
            tibble::as_tibble()

          if (mode[[1]] == "only_cached") {
            return(previous_ig_bd_media_df)
          }
        } else {
          # no need to create empty table
        }
      }

      out <- vector("list", max_pages %||% 10000)
      posts_l <- vector("list", max_pages %||% 10000)

      i <- 1L

      after_string_available <- fs::file_exists(path = after_string_path)

      if (mode[[1]] == "full" & after_string_available) {
        after_string <- readr::read_lines(file = after_string_path)

        if (after_string == "Earliest page reached") {
          cli::cli_inform(
            message = c(
              i = "No older posts available, returning cached data."
            )
          )
          return(previous_ig_bd_media_df)
        }

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
      } else {
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
      }

      cli::cli_progress_bar(
        name = cli::cli_text("Retrieving posts for user {.val {current_user}}:")
      )

      repeat {
        ({
          cli::cli_progress_update(inc = 25)

          resp <- api_request |>
            httr2::req_error(is_error = \(resp) FALSE) |>
            httr2::req_perform()

          if (!is.null(limit)) {
            limits_l <- resp$headers$`x-app-usage` |>
              jsonlite::parse_json(simplifyVector = TRUE)
            if (sum(limits_l > limit) >= 1) {
              over_limits <- limits_l[which.max(unlist(limits_l))]

              cli::cli_alert_warning(
                "Rate limit has reached threshold: {.var {names(over_limits)}} is now at {.val {over_limits}%}"
              )
              cli::cli_alert_success(
                "Returning the {.val {i}} pages retrieved so far, presumably corresponding to {.val {i*25}} posts."
              )
              cli::cli_alert_info(
                "Consider waiting for an hour for limits to reset, and set {.var wait} to 300 before retrying."
              )

              break
            }
          }

          req <- resp |>
            httr2::resp_body_json()

          if (is.null(req[["error"]][["message"]]) == FALSE) {
            cli::cli_alert_danger(req[["error"]][["message"]])
            cli::cli_alert_success(
              "Returning the {.val {i}} pages retrieved so far, presumably corresponding to {.val {i*25}} posts."
            )
            cli::cli_alert_info(
              "Consider waiting for an hour for limits to reset, and set {.var wait} to 300 before retrying."
            )
            break
          }

          current_set_l <- req |>
            purrr::pluck("business_discovery", "media", "data")

          current_post_set_details_df <- purrr::map(
            current_set_l,
            .f = function(current_set) {
              current_set |>
                tibble::as_tibble()
            }
          ) |>
            purrr::list_rbind() |>
            dplyr::rename(ig_media_id = id) |>
            dplyr::mutate(
              timestamp_retrieved = strftime(
                as.POSIXlt(Sys.time(), "UTC"),
                "%Y-%m-%dT%H:%M:%S%z"
              )
            ) |>
            dplyr::relocate(dplyr::all_of("ig_media_id"))

          if (!"thumbnail_url" %in% colnames(current_post_set_details_df)) {
            current_post_set_details_df <- current_post_set_details_df |>
              dplyr::mutate(thumbnail_url = NA_character_)
          }

          if (
            "like_count" %in%
              fields &
              !"like_count" %in% colnames(current_post_set_details_df)
          ) {
            current_post_set_details_df <- current_post_set_details_df |>
              dplyr::mutate(like_count = NA_integer_)
          }

          if (
            "view_count" %in%
              fields &
              !"view_count" %in% colnames(current_post_set_details_df)
          ) {
            current_post_set_details_df <- current_post_set_details_df |>
              dplyr::mutate(view_count = NA_integer_)
          }

          output_df <- current_post_set_details_df[c(
            "ig_media_id",
            fields_filter,
            "timestamp_retrieved"
          )]

          out[[i]] <- output_df

          if (cache) {
            DBI::dbWriteTable(
              conn = db,
              name = "ig_bd_media",
              value = output_df,
              append = TRUE
            )
          }

          if (
            purrr::pluck_exists(
              req,
              "business_discovery",
              "media",
              "paging",
              "cursors",
              "after"
            )
          ) {
            after_string <- purrr::pluck(
              req,
              "business_discovery",
              "media",
              "paging",
              "cursors",
              "after"
            )

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
              file = after_string_path
            )
          } else {
            readr::write_lines(
              x = "Earliest page reached",
              file = after_string_path
            )
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
      }

      newly_retrieved <- out |>
        purrr::list_rbind()

      if (mode[[1]] == "full") {
        dplyr::bind_rows(newly_retrieved, previous_ig_bd_media_df) |>
          dplyr::arrange(dplyr::desc(timestamp_retrieved)) |>
          dplyr::distinct(ig_media_id, .keep_all = TRUE) |>
          dplyr::arrange(dplyr::desc(timestamp)) |>
          dplyr::collect() |>
          tibble::as_tibble()
      } else {
        newly_retrieved
      }
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

  # if (cache) {
  #   DBI::dbDisconnect(conn = db)
  # }

  users_posts_df
}
