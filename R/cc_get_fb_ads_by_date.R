#' Get Facebook ads by date and store them locally
#'
#' @param date A vector of dates.
#'
#' @return
#' @export
#'
#' @examples
cc_get_fb_ads_by_date <- function(date,
                                  fields = c(
                                    "campaign_name",
                                    "campaign_id",
                                    "adset_name",
                                    "adset_id",
                                    "ad_name",
                                    "ad_id",
                                    "objective",
                                    "account_currency",
                                    "spend",
                                    "actions",
                                    "action_values",
                                    "cost_per_action_type",
                                    "cost_per_unique_action_type",
                                    "conversions",
                                    "cost_per_conversion",
                                    "conversion_rate_ranking",
                                    "cpc",
                                    "cpm",
                                    "cpp",
                                    "ctr",
                                    "frequency",
                                    "reach"
                                  )) {
  if (is.null(names(date))) {
    names(date) <- date
  }

  fs::dir_create("fb_ads_by_date_rds")

  local_rds <- fs::path(
    "fb_ads_by_date_rds",
    paste0(date, ".rds")
  )

  if (fs::file_exists(path = local_rds) == TRUE) {
    return(readr::read_rds(file = local_rds))
  } else {
    df_l <- fbRads::fb_insights(
      level = "ad",
      time_range = cc_date_to_json(start_date = date),
      fields = fields
    )

    df_ads <- data.table::rbindlist(df_l,
      fill = TRUE
    ) |>
      tibble::as_tibble()

    saveRDS(
      object = df_ads,
      file = local_rds
    )
    return(df_ads)
  }
}
