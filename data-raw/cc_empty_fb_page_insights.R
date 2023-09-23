## code to prepare `cc_empty_fb_page_insights` dataset goes here

cc_empty_fb_page_insights <- tibble::tibble(
  date = character(),
  metric = character(),
  metric_title = character(),
  period = character(),
  value = numeric(),
  end_time = character()
)

usethis::use_data(cc_empty_fb_page_insights, overwrite = TRUE)
