## code to prepare `cc_empty_fb_ad_creatives` dataset goes here

cc_empty_fb_ad_creatives_id <- tibble::tibble(
  ad_id = character(),
  creative_id = character(),
  timestamp_retrieved = character()
)

usethis::use_data(cc_empty_fb_ad_creatives_id, overwrite = TRUE)
