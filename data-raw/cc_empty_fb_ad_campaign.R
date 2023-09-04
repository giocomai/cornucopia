## code to prepare `cc_empty_fb_ad_campaign` dataset goes here

cc_empty_fb_ad_campaign <- tibble::tibble(
  campaign_id = character(),
  campaign_name = character(),
  created_time = character(),
  updated_time = character(),
  start_time = character(),
  stop_time = character(),
  objective = character(),
  status = character(),
  timestamp_retrieved = character()
)


usethis::use_data(cc_empty_fb_ad_campaign, overwrite = TRUE)
