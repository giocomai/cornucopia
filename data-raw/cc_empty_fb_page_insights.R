## code to prepare `cc_empty_fb_page_insights` dataset goes here

cc_empty_fb_page_insights <- tibble::tibble(
  date = character(),
  metric_title = character(),
  metric_name = character(),
  metric_value_name = character(),
  metric_value = numeric(),
  period = character()
)

usethis::use_data(cc_empty_fb_page_insights, overwrite = TRUE)
