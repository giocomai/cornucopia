#' Retrieve and store locally either orders or client items
#'
#' @param pages Defaults to `NULL`, or all available pages. If given, it
#'   downloads at most the given number of pages.
#' @param type Defaults to "orders". Expected to be either "order" or "client".
#' @param wait Defaults to 1. Seconds to wait between calls to the API.
#' @inheritParams cc_set
#'
#' @returns Nothing, only caches locally data.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_woocommerce_json(
#'   id = c(100:110),
#'   type = "orders")
#' }
cc_get_woocommerce_json_by_pagination <- function(
  pages = NULL,
  type = c("orders", "customers"),
  wait = 1,
  woocommerce_base_url = cornucopia::cc_get_woocommerce_base_url(),
  woocommerce_api_version = cornucopia::cc_get_woocommerce_api_version(),
  woocommerce_username = cornucopia::cc_get_settings()[[
    "woocommerce_username"
  ]],
  woocommerce_password = cornucopia::cc_get_settings()[[
    "woocommerce_password"
  ]],
  woocommerce_cache_folder = cornucopia::cc_get_settings()[[
    "woocommerce_cache_folder"
  ]]
) {
  cache_folder <- fs::path(woocommerce_cache_folder, type[[1]])
  previous_files_v <- fs::dir_ls(path = cache_folder)

  if (length(previous_files_v) == 0) {
    previous_id <- character()
  } else {
    previous_id <- previous_files_v |>
      fs::path_file() |>
      fs::path_ext_remove() |>
      as.character()
  }

  # Retrieve latest page
  req <- httr2::request(woocommerce_base_url) |>
    httr2::req_url_path_append(woocommerce_api_version) |>
    httr2::req_url_path_append(type[[1]]) |>
    httr2::req_auth_basic(
      username = woocommerce_username,
      password = woocommerce_password
    ) |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- req |>
    httr2::req_perform()

  max_pages_to_retrieve <- min(
    pages,
    resp |>
      httr2::resp_header("x-wp-totalpages") |>
      as.numeric()
  )

  pages_to_process_v <- 2:max_pages_to_retrieve

  resp_l <- resp |>
    httr2::resp_body_json()

  new_id_v <- purrr::map_chr(
    .x = resp_l,
    .f = \(current_item) {
      current_file <- fs::path(cache_folder, current_item[["id"]], ext = "rds")

      saveRDS(object = current_item, file = current_file)
      purrr::pluck(.x = current_item, "id") |> as.character()
    }
  )

  if (sum(new_id_v %in% previous_id) == length(new_id_v)) {
    cli::cli_alert_success(
      text = "Retrieval completed: no new items found after retrieving 1 page."
    )
    return(invisible(NULL))
  }

  for (current_page_id in as.character(pages_to_process_v)) {
    req <- httr2::request(woocommerce_base_url) |>
      httr2::req_url_path_append(woocommerce_api_version) |>
      httr2::req_url_path_append(type[[1]]) |>
      httr2::req_url_query(page = current_page_id) |>
      httr2::req_auth_basic(
        username = woocommerce_username,
        password = woocommerce_password
      ) |>
      httr2::req_error(is_error = \(resp) FALSE)

    resp <- req |>
      httr2::req_perform()

    if (isFALSE(resp)) {
      return(NULL)
    }

    resp_l <- resp |>
      httr2::resp_body_json()

    new_id_v <- purrr::map_chr(
      .x = resp_l,
      .f = \(current_item) {
        current_file <- fs::path(
          cache_folder,
          current_item[["id"]],
          ext = "rds"
        )

        saveRDS(object = current_item, file = current_file)
        purrr::pluck(.x = current_item, "id") |> as.character()
      }
    )

    cli::cli_alert_success(
      text = "Page {current_page_id} retrieved, with items {min(as.numeric(new_id_v))} to {max(as.numeric(new_id_v))}."
    )

    if (sum(new_id_v %in% previous_id) == length(new_id_v)) {
      cli::cli_alert_success(
        text = "Retrieval completed: no new items found after retrieving {current_page_id} pages."
      )
      return(invisible(NULL))
    }

    Sys.sleep(wait)
  }
}
