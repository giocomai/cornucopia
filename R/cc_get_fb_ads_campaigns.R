#' Get all campaigns for the current ad account
#'
#' For details on valid fields, see: https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/
#'
#' Draft: not yet caching or paging results
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_ads_campaigns()
#' }
cc_get_fb_ads_campaigns <- function(api_version = "v17.0",
                                    ad_account_id = NULL,
                                    token = NULL) {
  if (is.null(token)) {
    fb_user_token <- cc_get_settings(fb_user_token = token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(token)
  }

  if (is.null(ad_account_id)) {
    fb_ad_account_id <- cc_get_settings(fb_ad_account_id = ad_account_id) |>
      purrr::pluck("fb_ad_account_id")
  } else {
    fb_ad_account_id <- as.character(ad_account_id)
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(stringr::str_c("act_", fb_ad_account_id)) |>
    httr2::req_url_path_append("campaigns") |>
    httr2::req_url_query(
      fields = "id,name,created_time,updated_time,start_time,stop_time,objective,status",
      access_token = fb_user_token
    )

  req <- httr2::req_perform(req = api_request)

  response_l <- httr2::resp_body_json(req) |>
    purrr::pluck("data")

  campaigns_df <- purrr::map(
    .x = response_l,
    .f = function(x) {
      x |>
        tibble::as_tibble()
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::rename(
      campaign_id = id,
      campaign_name = name
    )

  campaigns_df
}
