#' Set settings and token for the session
#'
#' @param meta_api_version Defaults to the latest API at the time this package was
#'   last updated. Currently, this corresponds to api version 24.0.
#' @param start_date Defaults to 91 days before today
#' @param end_date Defaults to yesterday.
#' @param fb_user_token Facebook user token different from page token. Can be
#'   retrieved with [cc_get_fb_user_token()] or [cc_get_fb_long_user_token()].
#' @param fb_page_token Facebook page token, different from the user token. Can
#'   be retrieved with [cc_get_fb_page_token()] or
#'   [cc_get_fb_long_page_token()].
#' @param fb_page_id Facebook page identifier. Can be retrieved with
#'   [cc_get_fb_managed_pages()].
#' @param fb_business_id Facebook business id. For details on how to find it,
#'   see \url{https://www.facebook.com/business/help/1181250022022158}
#' @param ga_email E-mail addressed associated with relevant Google Analytics
#'   account, passed to `googleAnalyticsR::ga_auth()`
#' @param ga_property_id Google Analytics property identifier. Find it with
#'   `googleAnalyticsR::ga_account_list("ga4")`.
#' @return A list of named elements.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   dates_l <- cc_set()
#'   dates_l
#' }
#' }
#'
cc_set <- function(
  meta_api_version = "v24.0",
  start_date = NULL,
  end_date = NULL,
  fb_user_token = NULL,
  fb_page_token = NULL,
  fb_page_id = NULL,
  fb_business_id = NULL,
  fb_ad_account_id = NULL,
  fb_product_catalog_id = NULL,
  fb_user_id = NULL,
  ig_user_id = NULL,
  ga_email = NULL,
  ga_property_id = NULL,
  woocommerce_base_url = NULL,
  woocommerce_api_version = "v3",
  woocommerce_username = NULL,
  woocommerce_password = NULL,
  woocommerce_cache_folder = "woocommerce_cache"
) {
  if (is.null(meta_api_version)) {
    meta_api_version <- Sys.getenv("cornucopia_meta_api_version")
  } else {
    Sys.setenv(cornucopia_meta_api_version = as.character(meta_api_version))
  }

  if (is.null(start_date)) {
    start_date <- Sys.getenv("cornucopia_start_date")
  } else {
    Sys.setenv(cornucopia_start_date = as.character(start_date))
  }
  if (
    (is.na(start_date == "") & is.na(start_date)) |
      (is.na(start_date == "") == FALSE & start_date == "")
  ) {
    start_date <- Sys.Date() - 91
  }

  if (is.null(end_date)) {
    end_date <- Sys.getenv("cornucopia_end_date")
  } else {
    Sys.setenv(cornucopia_end_date = as.character(end_date))
  }
  if (
    (is.na(end_date == "") & is.na(end_date)) |
      (is.na(end_date == "") == FALSE & end_date == "")
  ) {
    end_date <- Sys.Date() - 1
  }

  if (is.null(fb_user_token)) {
    fb_user_token <- Sys.getenv("cornucopia_fb_user_token")
  } else {
    Sys.setenv(cornucopia_fb_user_token = as.character(fb_user_token))
  }

  if (is.null(fb_page_token)) {
    fb_page_token <- Sys.getenv("cornucopia_fb_page_token")
  } else {
    Sys.setenv(cornucopia_fb_page_token = as.character(fb_page_token))
  }

  if (is.null(fb_page_id)) {
    fb_page_id <- Sys.getenv("cornucopia_fb_page_id")
  } else {
    Sys.setenv(cornucopia_fb_page_id = as.character(fb_page_id))
  }

  if (is.null(fb_business_id)) {
    fb_business_id <- Sys.getenv("cornucopia_fb_business_id")
  } else {
    Sys.setenv(cornucopia_fb_business_id = as.character(fb_business_id))
  }

  if (is.null(fb_ad_account_id)) {
    fb_ad_account_id <- Sys.getenv("cornucopia_fb_ad_account_id")
  } else {
    Sys.setenv(cornucopia_fb_ad_account_id = as.character(fb_ad_account_id))
  }

  if (is.null(fb_product_catalog_id)) {
    fb_product_catalog_id <- Sys.getenv("cornucopia_fb_product_catalog_id")
  } else {
    Sys.setenv(
      cornucopia_fb_product_catalog_id = as.character(fb_product_catalog_id)
    )
  }

  if (is.null(fb_user_id)) {
    fb_user_id <- Sys.getenv("cornucopia_fb_user_id")
  } else {
    Sys.setenv(cornucopia_fb_user_id = as.character(fb_user_id))
  }

  if (is.null(ig_user_id)) {
    ig_user_id <- Sys.getenv("cornucopia_ig_user_id")
  } else {
    Sys.setenv(cornucopia_ig_user_id = as.character(ig_user_id))
  }

  if (is.null(ga_email)) {
    ga_email <- Sys.getenv("cornucopia_ga_email")
  } else {
    Sys.setenv(cornucopia_ga_email = as.character(ga_email))
  }

  if (is.null(ga_property_id)) {
    ga_property_id <- Sys.getenv("cornucopia_ga_property_id")
  } else {
    Sys.setenv(cornucopia_ga_property_id = as.character(ga_property_id))
  }

  if (is.null(woocommerce_base_url)) {
    woocommerce_base_url <- Sys.getenv("cornucopia_woocommerce_base_url")
  } else {
    Sys.setenv(
      cornucopia_woocommerce_base_url = as.character(woocommerce_base_url)
    )
  }

  if (is.null(woocommerce_api_version)) {
    woocommerce_api_version <- Sys.getenv("cornucopia_woocommerce_api_version")
  } else {
    Sys.setenv(
      cornucopia_woocommerce_api_version = as.character(woocommerce_api_version)
    )
  }

  if (is.null(woocommerce_username)) {
    woocommerce_username <- Sys.getenv("cornucopia_woocommerce_username")
  } else {
    Sys.setenv(
      cornucopia_woocommerce_username = as.character(woocommerce_username)
    )
  }

  if (is.null(woocommerce_password)) {
    woocommerce_password <- Sys.getenv("cornucopia_woocommerce_password")
  } else {
    Sys.setenv(
      cornucopia_woocommerce_password = as.character(woocommerce_password)
    )
  }

  if (is.null(woocommerce_cache_folder)) {
    woocommerce_cache_folder <- Sys.getenv(
      "cornucopia_woocommerce_cache_folder"
    )
  } else {
    Sys.setenv(
      cornucopia_woocommerce_cache_folder = as.character(
        woocommerce_cache_folder
      )
    )
  }

  invisible(list(
    meta_api_version = as.character(meta_api_version),
    start_date = lubridate::as_date(start_date),
    end_date = lubridate::as_date(end_date),
    fb_user_token = as.character(fb_user_token),
    fb_page_token = as.character(fb_page_token),
    fb_page_id = as.character(fb_page_id),
    fb_business_id = as.character(fb_business_id),
    fb_ad_account_id = as.character(fb_ad_account_id),
    fb_product_catalog_id = as.character(fb_product_catalog_id),
    fb_user_id = as.character(fb_user_id),
    ig_user_id = as.character(ig_user_id),
    ga_email = as.character(ga_email),
    ga_property_id = as.character(ga_property_id),
    woocommerce_base_url = as.character(woocommerce_base_url),
    woocommerce_api_version = as.character(woocommerce_api_version),
    woocommerce_username = as.character(woocommerce_username),
    woocommerce_password = as.character(woocommerce_password),
    woocommerce_cache_folder = as.character(woocommerce_cache_folder)
  ))
}


#' Retrieve settings for the session.
#'
#' Typically set with `cc_set()`.
#'
#' @param start_date Nominally defaults to NULL, but effectively to 91 days before today.
#' @param end_date Nominally defaults to NULL, but effectively to yesterday.
#'
#' @return A list of named elements.
#' @export
#' @examples
#' \donttest{
#' if (interactive()) {
#'   dates_l <- cc_get_settings()
#'   dates_l
#' }
#' }
#'
cc_get_settings <- function(
  meta_api_version = NULL,
  start_date = NULL,
  end_date = NULL,
  fb_user_token = NULL,
  fb_page_token = NULL,
  fb_page_id = NULL,
  fb_business_id = NULL,
  fb_ad_account_id = NULL,
  fb_product_catalog_id = NULL,
  fb_user_id = NULL,
  ig_user_id = NULL,
  ga_email = NULL,
  ga_property_id = NULL,
  woocommerce_base_url = NULL,
  woocommerce_api_version = NULL,
  woocommerce_username = NULL,
  woocommerce_password = NULL,
  woocommerce_cache_folder = NULL
) {
  if (is.null(meta_api_version)) {
    meta_api_version <- Sys.getenv(
      "cornucopia_meta_api_version",
      unset = "v24.0"
    )
  }

  if (is.null(start_date)) {
    start_date <- Sys.getenv("cornucopia_start_date")
  }
  if (
    (is.na(start_date == "") & is.na(start_date)) |
      (is.na(start_date == "") == FALSE & start_date == "")
  ) {
    start_date <- Sys.Date() - 91
  }

  if (is.null(end_date)) {
    end_date <- Sys.getenv("cornucopia_end_date")
  }

  if (
    (is.na(end_date == "") & is.na(end_date)) |
      (is.na(end_date == "") == FALSE & end_date == "")
  ) {
    end_date <- Sys.Date() - 1
  }

  if (is.null(fb_user_token)) {
    fb_user_token <- Sys.getenv("cornucopia_fb_user_token")
  }

  if (is.null(fb_page_token)) {
    fb_page_token <- Sys.getenv("cornucopia_fb_page_token")
  }

  if (is.null(fb_page_id)) {
    fb_page_id <- Sys.getenv("cornucopia_fb_page_id")
  }

  if (is.null(fb_business_id)) {
    fb_business_id <- Sys.getenv("cornucopia_fb_business_id")
  }

  if (is.null(fb_ad_account_id)) {
    fb_ad_account_id <- Sys.getenv("cornucopia_fb_ad_account_id")
  }

  if (is.null(fb_product_catalog_id)) {
    fb_product_catalog_id <- Sys.getenv("cornucopia_fb_product_catalog_id")
  }

  if (is.null(fb_user_id)) {
    fb_user_id <- Sys.getenv("cornucopia_fb_user_id")
  }

  if (is.null(ig_user_id)) {
    ig_user_id <- Sys.getenv("cornucopia_ig_user_id")
  }

  if (is.null(ga_email)) {
    ga_email <- Sys.getenv("cornucopia_ga_email")
  }

  if (is.null(ga_property_id)) {
    ga_property_id <- Sys.getenv("cornucopia_ga_property_id")
  }

  if (is.null(woocommerce_api_version)) {
    woocommerce_api_version <- Sys.getenv(
      "cornucopia_woocommerce_api_version",
      unset = "v3"
    )
  }

  if (is.null(woocommerce_base_url)) {
    woocommerce_base_url <- Sys.getenv("cornucopia_woocommerce_base_url")
  }

  if (is.null(woocommerce_username)) {
    woocommerce_username <- Sys.getenv("cornucopia_woocommerce_username")
  }

  if (is.null(woocommerce_password)) {
    woocommerce_password <- Sys.getenv("cornucopia_woocommerce_password")
  }

  if (is.null(woocommerce_cache_folder)) {
    woocommerce_cache_folder <- Sys.getenv(
      "cornucopia_woocommerce_cache_folder",
      unset = "woocommerce_cache"
    )
  }

  invisible(list(
    meta_api_version = as.character(meta_api_version),
    start_date = lubridate::as_date(start_date),
    end_date = lubridate::as_date(end_date),
    fb_user_token = as.character(fb_user_token),
    fb_page_token = as.character(fb_page_token),
    fb_page_id = as.character(fb_page_id),
    fb_business_id = as.character(fb_business_id),
    fb_ad_account_id = as.character(fb_ad_account_id),
    fb_product_catalog_id = as.character(fb_product_catalog_id),
    fb_user_id = as.character(fb_user_id),
    ig_user_id = as.character(ig_user_id),
    ga_email = as.character(ga_email),
    ga_property_id = as.character(ga_property_id),
    woocommerce_base_url = as.character(woocommerce_base_url),
    woocommerce_api_version = as.character(woocommerce_api_version),
    woocommerce_username = as.character(woocommerce_username),
    woocommerce_password = as.character(woocommerce_password),
    woocommerce_cache_folder = as.character(woocommerce_cache_folder)
  ))
}


#' Retrieve version of Meta API.
#'
#' @inheritParams cc_set
#'
#' @returns The META API version set for the current session as a character
#'   vector of length 1.
#' @export
#'
#' @examples
#' cc_get_meta_api_version()
#'
#' cc_get_meta_api_version("23.0")
#'
#' cc_set(meta_api_version = "24.0")
#'
#' cc_get_meta_api_version()
#'
#' cc_get_meta_api_version("23.0")
cc_get_meta_api_version <- function(meta_api_version = NULL) {
  cc_get_settings(meta_api_version = meta_api_version) |>
    purrr::pluck("meta_api_version")
}

#' Retrieve version of Woocommerce API.
#'
#' @inheritParams cc_set
#'
#' @returns The Woocommerce API version set for the current session as a
#'   character vector of length 1.
#' @export
#'
#' @examples
#' cc_get_woocommerce_api_version()
#'
#' cc_get_woocommerce_api_version("v3")
#'
#' cc_set(woocommerce_api_version = "v2")
#'
#' cc_get_woocommerce_api_version()
#'
#' cc_set(woocommerce_api_version = "v3")
cc_get_woocommerce_api_version <- function(woocommerce_api_version = NULL) {
  cc_get_settings(woocommerce_api_version = woocommerce_api_version) |>
    purrr::pluck("woocommerce_api_version")
}


#' Retrieve base url of Woocommerce API.
#'
#' Typically it follows a pattern such as: `https://www.example.com/wp-json/wc/`.
#' Do not include the API version (e.g. `v3`), which is set separately.
#'
#' @inheritParams cc_set
#'
#' @returns The base url as a character vector of length 1.
#' @export
#'
#' @examples
#' cc_get_woocommerce_base_url()
#'
#' cc_get_woocommerce_base_url("https://www.example.com/wp-json/wc/")
#'
#' cc_set(woocommerce_base_url = "https://www.example.com/custom/wp-json/wc/")
#'
#' cc_get_woocommerce_base_url()
cc_get_woocommerce_base_url <- function(woocommerce_base_url = NULL) {
  cc_get_settings(woocommerce_base_url = woocommerce_base_url) |>
    purrr::pluck("woocommerce_base_url")
}
