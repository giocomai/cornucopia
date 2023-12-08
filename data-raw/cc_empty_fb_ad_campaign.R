## code to prepare `cc_empty_fb_ad_campaign` dataset goes here


cc_empty_fb_ad_campaign <- cc_valid_fields_ad_campaign_group_v |>
  purrr::map_dfc(setNames, object = list(character())) |>
  dplyr::rename(
    campaign_id = id,
    campaign_name = name
  ) |>
  dplyr::mutate(timestamp_retrieved = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%S%z"))

usethis::use_data(cc_empty_fb_ad_campaign, overwrite = TRUE)
