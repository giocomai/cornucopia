#' Get all campaigns for the current ad account
#'
#' For details on fields, see: https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/
#'
#' It currently returns only fields that are always present for all campaigns: "id,name,created_time,updated_time,start_time,stop_time,objective,status"
#'
#' Cache updating currently suboptimal.
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_ad_campaigns()
#' }
cc_get_fb_ad_campaigns <- function(api_version = "v17.0",
                                   ad_account_id = NULL,
                                   max_pages = NULL,
                                   token = NULL,
                                   cache = TRUE,
                                   update = FALSE) {
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



  if (cache == TRUE) {
    if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
      cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
    }
    fs::dir_create("cornucopia_db")

    db <- DBI::dbConnect(
      drv = RSQLite::SQLite(),
      fs::path(
        "cornucopia_db",
        fs::path_ext_set(stringr::str_c("fb_", fb_ad_account_id), ".sqlite") |>
          fs::path_sanitize()
      )
    )

    current_table <- "fb_ad_campaigns"

    if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
      DBI::dbWriteTable(
        conn = db,
        name = current_table,
        value = cc_empty_fb_ad_campaign
      )
    }

    previous_ad_campaign_df <- DBI::dbReadTable(
      conn = db,
      name = current_table
    ) |>
      dplyr::collect() |>
      tibble::as_tibble() |>
      dplyr::group_by(campaign_id) |>
      dplyr::slice_max(timestamp_retrieved,
        n = 1,
        with_ties = FALSE
      ) |>
      dplyr::ungroup()

    if (nrow(previous_ad_campaign_df) > 0) {
      if (update == FALSE) {
        return(previous_ad_campaign_df)
      }
    }
  }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    api_version
  )

  out <- vector("list", max_pages %||% 1000)
  campaigns_l <- vector("list", max_pages %||% 1000)

  i <- 1L
  cli::cli_progress_bar(name = "Retrieving Facebook ad campaigns:")

  api_request <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(stringr::str_c("act_", fb_ad_account_id)) |>
    httr2::req_url_path_append("campaigns") |>
    httr2::req_url_query(
      fields = "id,name,created_time,updated_time,start_time,stop_time,objective,status",
      access_token = fb_user_token
    )

  repeat({
    cli::cli_progress_update(inc = 25)

    out[[i]] <- httr2::req_perform(api_request) |>
      httr2::resp_body_json()

    if (!is.null(max_pages) && i == max_pages) {
      break
    }

    req <- httr2::req_perform(req = api_request)

    response_l <- httr2::resp_body_json(req) |>
      purrr::pluck("data")

    current_campaigns_df <- purrr::map(
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
      ) |>
      dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z"))

    campaigns_l[[i]] <- current_campaigns_df

    if (nrow(current_campaigns_df) == 0) {
      break
    } else {
      if (cache == TRUE) {
        DBI::dbAppendTable(
          conn = db,
          name = current_table,
          value = current_campaigns_df
        )
      }
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

  cli::cli_process_done()

  campaigns_l |>
    purrr::list_rbind() |>
    tibble::as_tibble()
}
