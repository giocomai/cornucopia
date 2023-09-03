#' Takes all action results for all days when an ad is active
#'
#' Draft: no caching and returns only latest 25 days, as paging in data retrieval has not been enabled
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_ad_actions_by_day <- function(ad_id = NULL,
                                        type = "actions",
                                        only_cached = FALSE,
                                        api_version = "v17.0",
                                        cache = TRUE,
                                        ad_account_id = NULL,
                                        token = NULL) {
  if (!(type %in% c("actions", "action_values", "cost_per_action_type"))) {
    cli::cli_abort("Invalid type. Check documentation.")
  }

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

  ad_id_to_process_v <- ad_id

  purrr::map(
    .x = ad_id_to_process_v,
    .progress = stringr::str_c("Retrieving ad details"),
    .f = function(current_ad_id) {
      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(current_ad_id) |>
        httr2::req_url_path_append("insights") |>
        httr2::req_url_query(
          fields = type,
          access_token = fb_user_token,
          date_preset = "maximum",
          time_increment = 1
        )

      req <- httr2::req_perform(req = api_request)

      response_l <- httr2::resp_body_json(req) |>
        purrr::pluck("data")

      purrr::map(
        .x = response_l,
        .f = function(response_for_current_date) {
          purrr::map(.x = response_for_current_date[[type]], .f = function(x) {
            x |> tibble::as_tibble()
          }) |>
            purrr::list_rbind() |>
            dplyr::mutate(date = response_for_current_date[["date_start"]]) |>
            dplyr::relocate(date)
        }
      ) |>
        purrr::list_rbind() |>
        dplyr::mutate(ad_id = current_ad_id) |>
        dplyr::relocate(ad_id)
    }
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(value = as.numeric(value))
}
