## code to prepare `cc_empty_fb_page_video_df` dataset goes here


cc_empty_fb_page_video_df <- tibble::tibble(
  created_time = character(),
  id = character(),
  title = character(),
  description = character(),
  post_id = character(),
  post_views = character(),
  views = character(),
  permalink_url = character(),
  embed_html = character(),
  embeddable = character(),
  source = character(),
  icon = character(),
  is_instagram_eligible = character(),
  length = character(),
  live_status = character(),
  universal_video_id = character(),
  updated_time = character()
)

usethis::use_data(cc_empty_fb_page_video_df, overwrite = TRUE)
