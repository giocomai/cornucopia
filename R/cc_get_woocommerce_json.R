#' Retrieve and store locally either orders or client items
#'
#' @param id An identifier of either order or client, according to what is set
#'   in `type`. Coerced to a character vector.
#' @param type Defaults to "orders". Expected to be either "order" or "client".
#' @param wait Defaults to 1. Seconds to wait between calls to the API
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
cc_get_woocommerce_json <- function(
  id = NULL,
  type = c("orders", "clients"),
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
  id <- as.character(id)

  if (length(previous_files_v) == 0) {
    id_to_process <- id
  } else {
    previous_id <- previous_files_v |>
      fs::path_file() |>
      fs::path_ext_remove() |>
      as.character()

    id_to_process <- id[!(id %in% previous_id)]
  }

  purrr::walk(
    .progress = TRUE,
    .x = as.character(id_to_process),
    .f = \(id) {
      current_file <- fs::path(cache_folder, fs::path_ext_set(id, "rds"))

      req <- httr2::request(woocommerce_base_url) |>
        httr2::req_url_path_append(woocommerce_api_version) |>
        httr2::req_url_path_append(type[[1]]) |>
        httr2::req_url_path_append(id) |>
        httr2::req_auth_basic(
          username = woocommerce_username,
          password = woocommerce_password
        ) |>
        httr2::req_error(is_error = \(resp) FALSE)

      resp <- req |>
        httr2::req_perform()

      if (isFALSE(resp)) {
        cli::cli_alert_info(
          text = "{stringr::str_remove(string = type[[1]], pattern = 's$') |> stringr::str_to_title()} with {.var id} {.val {id}} does not exist."
        )
        saveRDS(object = FALSE, file = current_file)
        return(NULL)
      }

      resp_l <- resp |>
        httr2::resp_body_json()

      saveRDS(object = resp_l, file = current_file)
      Sys.sleep(wait)
    }
  )
}
