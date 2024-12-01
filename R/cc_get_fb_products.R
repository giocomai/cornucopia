#' Get information about a Facebook catalog products
#'
#' Data are not cached locally.
#'
#' @return A data frame. Some columns include nested data.
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_products()
#' }
cc_get_fb_products <- function(fb_product_catalog_id = NULL,
                               fields = cc_valid_fields_fb_product,
                               api_version = "v21.0",
                               max_pages = NULL,
                               token = NULL) {
  if (is.null(token)) {
    fb_user_token <- cc_get_settings(fb_user_token = token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(token)
  }

  if (is.null(fb_product_catalog_id)) {
    fb_product_catalog_id <- cc_get_settings(fb_product_catalog_id = fb_product_catalog_id) |>
      purrr::pluck("fb_product_catalog_id")
  } else {
    fb_product_catalog_id <- as.character(fb_product_catalog_id)
  }

  if (fb_product_catalog_id == "") {
    cli::cli_abort("`fb_product_catalog_id` must be given.")
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  if (is.null(max_pages)) {
    api_request <- httr2::request(base_url = base_url) |>
      httr2::req_url_path_append(fb_product_catalog_id) |>
      httr2::req_url_path_append("products") |>
      httr2::req_url_query(
        fields = "id",
        access_token = fb_user_token,
        summary = "true"
      )

    req <- httr2::req_perform(req = api_request)

    total_count <- httr2::resp_body_json(req) |>
      purrr::pluck("summary", "total_count") |>
      as.numeric()
    max_pages <- ceiling(total_count / 25) + 1
  }

  fields_v <- stringr::str_c(fields, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_product_catalog_id) |>
    httr2::req_url_path_append("products") |>
    httr2::req_url_query(
      fields = fields_v,
      access_token = fb_user_token,
      summary = "true"
    )


  out <- vector("list", max_pages %||% 1000)
  out_post <- vector("list", max_pages %||% 1000)

  i <- 1L
  cli::cli_progress_bar(name = "Retrieving products from catalog:")

  repeat({
    cli::cli_progress_update(inc = 25)

    out[[i]] <- httr2::req_perform(api_request) |>
      httr2::resp_body_json()

    if (!is.null(max_pages) && i == max_pages) {
      break
    }

    out_post[[i]] <- purrr::map(
      .x = out[[i]][["data"]],
      .f = function(current_item) {
        commerce_insights_df <- tibble::as_tibble(current_item$commerce_insights)
        current_item$commerce_insights <- NULL

        product_catalog_df <- tibble::as_tibble(current_item$product_catalog) |>
          dplyr::rename(
            product_catalog_id = id,
            product_catalog_name = name
          )
        current_item$product_catalog <- NULL

        product_group_df <- tibble::as_tibble(current_item$product_group) |>
          dplyr::rename(
            product_group_id = id,
            product_group_retailer_id = retailer_id
          )
        current_item$product_group <- NULL

        current_item$additional_image_urls <- list(current_item$additional_image_urls)

        current_item$image_cdn_urls <- list(current_item$image_cdn_urls)
        current_item$additional_image_cdn_urls <- list(current_item$additional_image_cdn_urls)

        current_item$capability_to_review_status <- list(purrr::map(current_item$capability_to_review_status, .f = function(x) tibble::as_tibble(x)) |>
          purrr::list_rbind())

        current_item$images <- list(
          purrr::map(
            .x = current_item$images,
            .f = function(x) {
              temp_l <- jsonlite::parse_json(x)

              if (length(temp_l$tags) == 0) {
                temp_l$tags <- NA_character_
              }

              tibble::as_tibble(temp_l) |>
                dplyr::rename(
                  url_image = url,
                  tag_image = tags
                )
            }
          ) |> purrr::list_rbind()
        )


        if (length(current_item$additional_variant_attributes) == 0) {
          current_item$additional_variant_attributes <- list(NA_character_)
        }
        if (length(current_item$custom_data) == 0) {
          current_item$custom_data <- list(NA_character_)
        }


        dplyr::bind_cols(
          tibble::as_tibble(current_item),
          commerce_insights_df,
          product_catalog_df,
          product_group_df
        ) 
      }
    ) |>
      purrr::list_rbind()

    if (nrow(out_post[[i]]) == 0) {
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

  output_df <- purrr::list_rbind(out_post)

  output_df
}
