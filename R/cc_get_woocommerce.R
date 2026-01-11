#' Retrieve and extract in a data frame either orders or client items
#'
#' @inheritParams cc_get_woocommerce_json
#' @inheritParams cc_set
#'
#' @returns Returns main data retrieved from the API as a data frame.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_woocommerce(
#'   id = c(100:110),
#'   type = "orders")
#' }
cc_get_woocommerce <- function(
  id = NULL,
  type = c("orders", "clients"),
  only_cached = FALSE,
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

  if (type[[1]] != "orders") {
    cli::cli_abort("Only {.var orders} supported at this time")
  }

  if (length(previous_files_v) == 0) {
    id_to_download <- id
  } else {
    previous_id <- previous_files_v |>
      fs::path_file() |>
      fs::path_ext_remove() |>
      as.character()

    id_to_download <- id[!(id %in% previous_id)]
  }

  if (length(id_to_download) > 0 & !only_cached) {
    cc_get_woocommerce_json(
      id = id_to_download,
      type = type,
      wait = wait,
      woocommerce_base_url = woocommerce_base_url,
      woocommerce_api_version = woocommerce_api_version,
      woocommerce_username = woocommerce_username,
      woocommerce_password = woocommerce_password,
      woocommerce_cache_folder = woocommerce_cache_folder
    )

    previous_files_v <- fs::dir_ls(path = cache_folder)
  }

  previous_id <- previous_files_v |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    as.character()

  files_to_extract_v <- previous_files_v[(previous_id %in% id)]

  orders_l <- purrr::map(
    .progress = TRUE,
    .x = files_to_extract_v,
    .f = \(current_file) {
      order_l <- readr::read_rds(current_file)

      if (isFALSE(order_l)) {
        return(NULL)
      } else if (!is.null(order_l[["code"]])) {
        return(NULL)
      }

      base_df <- order_l[
        purrr::map_chr(
          .x = order_l,
          .f = \(x) class(x)
        ) %in%
          c("character", "integer", "logical")
      ] |>
        tibble::as_tibble()

      billing_df <- order_l |>
        purrr::pluck("billing") |>
        tibble::as_tibble()

      metadata_df <- purrr::map(
        .x = order_l[["meta_data"]],
        .f = \(x) {
          if (
            length(x) == 3 & !is.list(x[["value"]]) | length(x[["value"]]) == 1
          ) {
            temp_df <- x |>
              as.data.frame() |>
              dplyr::select(-id)

            names(temp_df)[[2]] <- "value"

            current_metadata_output_df <- temp_df |>
              tidyr::pivot_wider(names_from = key, values_from = value)
          } else {
            x_value <- x |>
              purrr::pluck("value", .default = NA)

            if (sum(purrr::map_lgl(.x = x_value, .f = \(x) is.null(x)) > 0)) {
              current_metadata_output_df <- x_value |>
                purrr::map_dfr(.f = \(x) x)
            } else {
              current_metadata_output_df <- x_value |>
                tibble::as_tibble()

              if (nrow(current_metadata_output_df) > 1) {
                current_metadata_output_df <- x_value |>
                  as.data.frame() |>
                  tibble::as_tibble()
              }
            }
          }

          current_metadata_output_df
        }
      ) |>
        purrr::list_cbind()

      base_df |>
        dplyr::bind_cols(
          billing_df
        ) |>
        dplyr::bind_cols(
          metadata_df
        )
    }
  )

  orders_df <- orders_l |>
    purrr::list_rbind()

  orders_df
}
