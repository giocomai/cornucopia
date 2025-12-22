#' Retrieve leads from lead ads
#'
#' Currently does not cache results.
#'
#' Details about the API:
#' https://developers.facebook.com/docs/marketing-api/guides/lead-ads/retrieving
#'
#' For the exact meaning of fields, see:
#' https://www.facebook.com/business/help/974763215942961?id=735435806665862
#'
#' Either a page or user token can be given. If both are given, page token is
#' used.
#'
#' In either case, be mindful of permission requirements:
#'
#' To read ad specific fields, such as ad_id, campaign_id, you will need:
#'
#' - A Page or User access token requested by a person who can advertise on the ad account and on the Page
#' - The ads_management permission
#' - The pages_read_engagement permission
#' - The pages_show_list permission
#' - The pages_manage_metadata permission - if using webhooks
#'
#' To read all lead data and ad level data, you will need:
#'
#' - A Page or User access token requested by a person who can advertise on the ad account and on the Page
#' - The ads_management permission
#' - The leads_retrieval permission
#' - The pages_show_list permission
#' - The pages_read_engagement permission
#' - The pages_manage_ads permission
#'
#'
#' @param form_id Identifier of the lead gen form, presumably an id of about 17
#'   digits.
#' @param fields Defaults to `c("created_time", "id", "ad_id", "form_id",
#'   "field_data")`-
#' @param fb_page_token Takes precedence over `fb_user_token`. See documentation
#'   for required permissions.
#' @param fb_user_token Used as a fallback option if `fb_page_token` not given.
#'   See documentation for required permissions.
#' @param max_pages Maximum number of pages to retrieve (15 responses are
#'   included in each page). Defaults to 1000 pages internally.
#' @inheritParams cc_set
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_leads(form_id = "12345678912345678")
#' }
cc_get_fb_leads <- function(
  form_id,
  fields = c(
    "created_time",
    "id",
    "campaign_id",
    "campaign_name",
    "adset_id",
    "adset_name",
    "ad_id",
    "ad_name",
    "form_id",
    "is_organic",
    "platform",
    "field_data"
  ),
  fb_page_token = NULL,
  fb_user_token = NULL,
  max_pages = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version()
) {
  form_id <- stringr::str_remove(
    string = form_id,
    pattern = stringr::fixed("f:")
  )

  if (is.null(fb_page_token)) {
    fb_page_token <- cc_get_settings(fb_page_token = fb_page_token) |>
      purrr::pluck("fb_page_token")
  } else {
    fb_page_token <- as.character(fb_page_token)
  }

  if (fb_page_token == "") {
    if (is.null(fb_user_token)) {
      fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
        purrr::pluck("fb_user_token")
    } else {
      fb_user_token <- as.character(fb_user_token)
    }
    token <- fb_user_token
  } else {
    token <- fb_page_token
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    meta_api_version
  )

  fields_v <- stringr::str_flatten(fields, collapse = ",")
  out <- vector("list", max_pages %||% 1000)
  all_responses_l <- vector("list", max_pages %||% 1000)

  i <- 1L
  cli::cli_progress_bar(name = "Retrieving leads:")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(form_id) |>
    httr2::req_url_path_append("leads") |>
    httr2::req_url_query(
      access_token = token,
      fields = fields_v
    )

  repeat {
    ({
      cli::cli_progress_update(inc = 25)

      if (!is.null(max_pages) && i == max_pages) {
        break
      }

      req_json <- api_request |>
        httr2::req_error(is_error = \(resp) FALSE) |>
        httr2::req_perform() |>
        httr2::resp_body_json()

      if (is.null(req_json[["error"]][["message"]]) == FALSE) {
        cli::cli_abort(req_json[["error"]][["message"]])
      }

      out[[i]] <- req_json

      response_l <- req_json |>
        purrr::pluck("data")

      responses_df <- purrr::map(
        .x = response_l,
        .f = function(current_response) {
          current_response_df <- current_response[
            1:length(current_response) - 1
          ] |>
            tibble::as_tibble() |>
            dplyr::bind_cols(
              purrr::map(
                .x = current_response[["field_data"]],
                .f = function(current_field) {
                  field_df <- tibble::tibble(
                    value = stringr::str_flatten(
                      unlist(current_field[["values"]]),
                      collapse = ";"
                    )
                  )
                  names(field_df) <- current_field[["name"]]
                  field_df
                }
              ) |>
                purrr::list_cbind()
            )
          current_response_df
        }
      ) |>
        purrr::list_rbind()

      all_responses_l[[i]] <- responses_df

      if (nrow(responses_df) == 0) {
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
  }

  cli::cli_process_done()

  purrr::list_rbind(all_responses_l)
}
