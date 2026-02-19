cc_empty_fb_page_insights_breakdown <- tibble::tibble(
  date = character(),
  metric_name = character(),
  breakdown_name = character(),
  breakdown_value = logical(),
  metric_value = numeric()
)

usethis::use_data(cc_empty_fb_page_insights_breakdown, overwrite = TRUE)
