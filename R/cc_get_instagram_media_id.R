#' Get identifiers of all media published on a profile
#'
#' @param max_pages Defaults to NULL. If not given, it retrieves the number of media and calculates max number of pages needed. Hard-coded max number of pages at 1000.
#' @inheritParams cc_get_instagram_user
#'
#' @return A tibble with one column named `ig_media_id` with identifiers of Instagram media.
#' @export
#'
#' @examples
cc_get_instagram_media_id <- function(ig_user_id = NULL,
                                      api_version = "v17.0",
                                      token = NULL,
                                      max_pages = NULL) {
  if (is.null(max_pages)) {
    media_count <- cc_get_instagram_user(
      ig_user_id = ig_user_id,
      api_version = api_version,
      fields = "media_count"
    ) |>
      purrr::pluck("media_count")
    max_pages <- ceiling(media_count / 25)
  }

  if (is.null(ig_user_id)) {
    ig_user_id <- cc_get_settings(ig_user_id = ig_user_id) |>
      purrr::pluck("ig_user_id")
  } else {
    ig_user_id <- as.character(ig_user_id)
  }

  if (is.null(token)) {
    fb_user_token <- cc_get_settings(fb_user_token = token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(token)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(ig_user_id) |>
    httr2::req_url_path_append("media") |>
    httr2::req_url_query(access_token = fb_user_token)


  # https://github.com/r-lib/httr2/issues/8#issuecomment-866221516

  out <- vector("list", max_pages %||% 1000)

  i <- 1L

  repeat({
    out[[i]] <- httr2::req_perform(api_request) |>
      httr2::resp_body_json()
    if (!is.null(max_pages) && i == max_pages) {
      break
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

  media_id_l <- purrr::map(
    .x = out,
    .f = function(x) {
      purrr::map_chr(
        .x = purrr::pluck(x, "data"),
        .f = function(y) {
          purrr::pluck(y, "id")
        }
      )
    }
  )

  media_id_df <- purrr::map(
    .x = media_id_l,
    .f = function(x) {
      tibble::tibble(ig_media_id = x)
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::arrange(dplyr::desc(ig_media_id))

  media_id_df
}
