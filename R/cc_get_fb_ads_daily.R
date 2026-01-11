#' Get all campaigns for the current ad account / legacy
#'
#' For details on fields, see \url{https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/}
#'
#' It currently returns all fields that return a single value,
#' `cc_valid_fields_ad_campaign_group_v`
#'
#' For reference, these are the fields that are always present for all
#' campaigns:
#' "id,name,created_time,updated_time,start_time,stop_time,objective,status"
#'
#' Cache updating currently suboptimal.
#'
#' @param fields A character vector of fields to retrieve. Defaults to "spend".
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' cc_get_fb_ads_daily()
#' }
cc_get_fb_ads_daily <- function(
  fields = c("spend"),
  level = "campaign",
  start_date = NULL,
  end_date = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_ad_account_id = NULL,
  max_pages = NULL,
  fb_user_token = NULL,
  cache = TRUE,
  update = TRUE
) {
  rlang::arg_match(level, values = c("campaign", "adset", "ad"))

  if (is.null(fb_user_token)) {
    fb_user_token <- cc_get_settings(fb_user_token = fb_user_token) |>
      purrr::pluck("fb_user_token")
  } else {
    fb_user_token <- as.character(fb_user_token)
  }

  if (is.null(fb_ad_account_id)) {
    fb_ad_account_id <- cc_get_settings(fb_ad_account_id = fb_ad_account_id) |>
      purrr::pluck("fb_ad_account_id")
  } else {
    fb_ad_account_id <- as.character(fb_ad_account_id)
  }

  if (is.null(start_date)) {
    start_date <- cc_get_settings(start_date = start_date) |>
      purrr::pluck("start_date")
  } else {
    start_date <- as.character(start_date)
  }

  if (is.null(end_date)) {
    end_date <- cc_get_settings(end_date = end_date) |>
      purrr::pluck("end_date")
  } else {
    end_date <- as.character(end_date)
  }

  all_dates_v <- seq.Date(
    from = lubridate::as_date(start_date),
    to = lubridate::as_date(end_date),
    by = "day"
  )

  dates_to_process_v <- all_dates_v

  # if (cache == TRUE) {
  #   if (requireNamespace("RSQLite", quietly = TRUE) == FALSE) {
  #     cli::cli_abort("Package `RSQLite` needs to be installed when `cache` is set to TRUE. Please install `RSQLite` or set cache to FALSE.")
  #   }
  #   fs::dir_create("cornucopia_db")
  #
  #   db <- DBI::dbConnect(
  #     drv = RSQLite::SQLite(),
  #     fs::path(
  #       "cornucopia_db",
  #       fs::path_ext_set(stringr::str_c("fb_", fb_ad_account_id), ".sqlite") |>
  #         fs::path_sanitize()
  #     )
  #   )
  #
  #   current_table <- "fb_ad_campaigns"
  #
  #   if (DBI::dbExistsTable(conn = db, name = current_table) == FALSE) {
  #     DBI::dbWriteTable(
  #       conn = db,
  #       name = current_table,
  #       value = tibble::as_tibble(cc_empty_fb_ad_campaign)
  #     )
  #   }
  #
  #   previous_ad_campaign_df <- DBI::dbReadTable(
  #     conn = db,
  #     name = current_table
  #   ) |>
  #     dplyr::collect() |>
  #     tibble::as_tibble()
  #
  #   if (nrow(previous_ad_campaign_df) > 0) {
  #     previous_ad_campaign_df <- previous_ad_campaign_df |>
  #       dplyr::group_by(campaign_id) |>
  #       dplyr::slice_max(timestamp_retrieved,
  #                        n = 1,
  #                        with_ties = FALSE
  #       ) |>
  #       dplyr::ungroup()
  #
  #     if (update == FALSE) {
  #       output_df <- previous_ad_campaign_df |>
  #         dplyr::collect()
  #       DBI::dbDisconnect(db)
  #       return(previous_ad_campaign_df)
  #     }
  #   }
  # }

  base_url <- stringr::str_c(
    "https://graph.facebook.com/",
    meta_api_version
  )

  ### check valid fields ####
  fields <- fields[
    !(fields %in%
      c(
        stringr::str_c(c("campaign", "adset", "ad"), "_id"),
        stringr::str_c(c("campaign", "adset", "ad"), "_name"),
        "id",
        "name"
      ))
  ]

  id_fields <- c(
    stringr::str_c(level, "_id"),
    stringr::str_c(level, "_name")
  )

  fields_v <- stringr::str_c(c(id_fields, fields), collapse = ",")

  new_df <- purrr::map(
    .x = dates_to_process_v,
    .progress = TRUE,
    .f = function(current_date) {
      out <- vector("list", max_pages %||% 1000)
      campaigns_l <- vector("list", max_pages %||% 1000)

      i <- 1L
      # cli::cli_progress_bar(name = "Retrieving Facebook ad campaigns:")

      api_request <- httr2::request(base_url = base_url) |>
        httr2::req_url_path_append(stringr::str_c("act_", fb_ad_account_id)) |>
        httr2::req_url_path_append("insights") |>
        #  httr2::req_url_path_append("day") |>
        httr2::req_url_query(
          fields = fields_v,
          level = "campaign",
          access_token = fb_user_token,
          limit = 1000,
          time_range = cc_date_to_json(
            start_date = current_date,
            end_date = current_date
          )
        )

      repeat {
        ({
          # cli::cli_progress_update(inc = 25)

          response_l <- api_request |>
            httr2::req_error(is_error = \(resp) FALSE) |>
            httr2::req_perform() |>
            httr2::resp_body_json()

          if (is.null(response_l[["error"]][["message"]]) == FALSE) {
            cli::cli_abort(response_l[["error"]][["message"]])
          }

          out[[i]] <- response_l

          if (!is.null(max_pages) && i == max_pages) {
            break
          }

          response_data_l <- response_l |>
            purrr::pluck("data")

          current_campaigns_df <- purrr::map(
            .x = response_data_l,
            .f = function(x) {
              extracted_data_df <- purrr::map2(
                .x = x[3:(length(x) - 2)],
                .y = names(x)[3:(length(x) - 2)],
                .f = function(current_x, current_name) {
                  # if (inherits(current_x, "character")) {
                  if (is.list(current_x)) {
                    current_element_df <- purrr::map(
                      .x = current_x,
                      .f = function(current_list_element) {
                        current_list_element |>
                          tibble::as_tibble()
                      }
                    ) |>
                      purrr::list_rbind() |>
                      dplyr::mutate(field_name = current_name) |>
                      dplyr::relocate(3, 1, 2)

                    names(current_element_df) <- c(
                      "field_name",
                      "field_type",
                      "field_value"
                    )
                    current_element_df
                  } else {
                    tibble::tibble(
                      field_name = current_name,
                      field_type = NA_character_,
                      field_value = current_x
                    )
                  }
                }
              ) |>
                purrr::list_rbind() |>
                dplyr::mutate(
                  date = current_date,
                  id = x[[1]],
                  name = x[[2]]
                ) |>
                dplyr::relocate(dplyr::all_of("date", "id", "name"))

              names(extracted_data_df)[2] <- names(x)[[1]]
              names(extracted_data_df)[3] <- names(x)[[2]]

              extracted_data_df
            }
          ) |>
            purrr::list_rbind() |>
            dplyr::mutate(
              timestamp_retrieved = strftime(
                as.POSIXlt(Sys.time(), "UTC"),
                "%Y-%m-%dT%H:%M:%S%z"
              )
            )

          campaigns_l[[i]] <- current_campaigns_df

          if (nrow(current_campaigns_df) == 0) {
            break
          } else {
            # if (cache == TRUE) {
            #   DBI::dbAppendTable(
            #     conn = db,
            #     name = current_table,
            #     value = current_campaigns_df
            #   )
            #
            #   if (nrow(dplyr::anti_join(
            #     x = current_campaigns_df,
            #     y = previous_ad_campaign_df,
            #     by = "campaign_id"
            #   )) < nrow(current_campaigns_df)) {
            #     break
            #   }
            # }
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

      # cli::cli_process_done()

      new_campaigns_df <- campaigns_l |>
        purrr::list_rbind() |>
        tibble::as_tibble() |>
        dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
    }
  )

  all_new_df <- new_df |>
    purrr::list_rbind()

  #
  # if (cache == TRUE) {
  #   if (nrow(new_campaigns_df) > 0) {
  #     output_ad_campaign_df <- dplyr::bind_rows(
  #       new_campaigns_df,
  #       previous_ad_campaign_df
  #     ) |>
  #       dplyr::group_by(campaign_id) |>
  #       dplyr::slice_max(timestamp_retrieved,
  #                        n = 1,
  #                        with_ties = FALSE
  #       ) |>
  #       dplyr::ungroup()
  #     DBI::dbDisconnect(db)
  #   } else {
  #     output_ad_campaign_df <- previous_ad_campaign_df
  #   }
  # } else {
  #   return(new_campaigns_df)
  # }
  #
  # dplyr::bind_rows(
  #   cc_empty_fb_ad_campaign,
  #   output_ad_campaign_df
  # )
  return(all_new_df)
}
