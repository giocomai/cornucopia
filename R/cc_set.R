#' Set settings and token for the session
#'
#'
#' @param start_date Defaults to 91 days before today
#' @param end_date Defaults to yesterday.
#' @param fb_user_token Facebook user token (not a page token).
#' @param fb_business_id Facebook business id. For details on how to find it,
#'   see \url{https://www.facebook.com/business/help/1181250022022158}
#'
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
cc_set <- function(start_date = NULL,
                   end_date = NULL,
                   fb_user_token = NULL,
                   fb_page_token = NULL,
                   fb_page_id = NULL,
                   fb_business_id = NULL,
                   fb_ad_account_id = NULL,
                   fb_product_catalog_id = NULL,
                   fb_user_id = NULL,
                   ig_user_id = NULL) {
  if (is.null(start_date)) {
    start_date <- Sys.getenv("cornucopia_start_date")
  } else {
    Sys.setenv(cornucopia_start_date = as.character(start_date))
  }
  if ((is.na(start_date == "") & is.na(start_date)) | (is.na(start_date == "") == FALSE & start_date == "")) {
    start_date <- Sys.Date() - 91
  }

  if (is.null(end_date)) {
    end_date <- Sys.getenv("cornucopia_end_date")
  } else {
    Sys.setenv(cornucopia_end_date = as.character(end_date))
  }
  if ((is.na(end_date == "") & is.na(end_date)) | (is.na(end_date == "") == FALSE & end_date == "")) {
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
    Sys.setenv(cornucopia_fb_product_catalog_id = as.character(fb_product_catalog_id))
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





  invisible(list(
    start_date = lubridate::as_date(start_date),
    end_date = lubridate::as_date(end_date),
    fb_user_token = as.character(fb_user_token),
    fb_page_token = as.character(fb_page_token),
    fb_page_id = as.character(fb_page_id),
    fb_business_id = as.character(fb_business_id),
    fb_ad_account_id = as.character(fb_ad_account_id),
    fb_product_catalog_id = as.character(fb_product_catalog_id),
    fb_user_id = as.character(fb_user_id),
    ig_user_id = as.character(ig_user_id)
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
cc_get_settings <- function(start_date = NULL,
                            end_date = NULL,
                            fb_user_token = NULL,
                            fb_page_token = NULL,
                            fb_page_id = NULL,
                            fb_business_id = NULL,
                            fb_ad_account_id = NULL,
                            fb_product_catalog_id = NULL,
                            fb_user_id = NULL,
                            ig_user_id = NULL) {
  if (is.null(start_date)) {
    start_date <- Sys.getenv("cornucopia_start_date")
  }
  if ((is.na(start_date == "") & is.na(start_date)) | (is.na(start_date == "") == FALSE & start_date == "")) {
    start_date <- Sys.Date() - 91
  }

  if (is.null(end_date)) {
    end_date <- Sys.getenv("cornucopia_end_date")
  }

  if ((is.na(end_date == "") & is.na(end_date)) | (is.na(end_date == "") == FALSE & end_date == "")) {
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

  invisible(list(
    start_date = lubridate::as_date(start_date),
    end_date = lubridate::as_date(end_date),
    fb_user_token = as.character(fb_user_token),
    fb_page_token = as.character(fb_page_token),
    fb_page_id = as.character(fb_page_id),
    fb_business_id = as.character(fb_business_id),
    fb_ad_account_id = as.character(fb_ad_account_id),
    fb_product_catalog_id = as.character(fb_product_catalog_id),
    fb_user_id = as.character(fb_user_id),
    ig_user_id = as.character(ig_user_id)
  ))
}
