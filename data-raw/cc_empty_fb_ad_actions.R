## code to prepare `cc_empty_fb_ad_actions` dataset goes here

cc_empty_fb_ad_actions <- tibble::tibble(
  ad_id = character(),
  date = character(),
  action_type = character(),
  value = numeric()
)

usethis::use_data(cc_empty_fb_ad_actions, overwrite = TRUE)
