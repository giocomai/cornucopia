#' Get information about your Facebook product catalogs
#'
#' See the relevant page in the documentation for available fields and more details
#' https://developers.facebook.com/docs/marketing-api/reference/product-catalog
#'
#' @param api_version Defaults to "v21.0".
#' @param fields Defaults to all available.
#' @param token Facebook user token (not a page token).
#' @inheritParams cc_set
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_owned_product_catalogs()
#' }
cc_get_fb_owned_product_catalogs <- function(fb_business_id = NULL,
                                             api_version = "v21.0",
                                             fields = c(
                                               "id",
                                               "business",
                                               "commerce_merchant_settings",
                                               "da_display_settings",
                                               "default_image_url",
                                               "fallback_image_url",
                                               "feed_count",
                                               "is_catalog_segment",
                                               "name",
                                               "product_count",
                                               "vertical"
                                             ),
                                             token = NULL) {
  if (is.null(fb_business_id)) {
    fb_business_id <- cc_get_settings(fb_business_id = fb_business_id) |>
      purrr::pluck("fb_business_id")
  } else {
    fb_business_id <- as.character(fb_business_id)
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

  fields_v <- stringr::str_c(fields, collapse = ",")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(fb_business_id) |>
    httr2::req_url_path_append("owned_product_catalogs") |>
    httr2::req_url_query(
      fields = fields_v,
      access_token = fb_user_token
    )

  req <- httr2::req_perform(req = api_request)

  tibble::as_tibble(httr2::resp_body_json(req))
}
