cc_empty_fb_page_post_comments_df <- tibble::tibble(
  created_time = character(),
  message = character(),
  comment_id = character(),
  from_name = character(),
  from_id = character(),
  fb_post_id = character(),
  timestamp_retrieved = character()
)
usethis::use_data(cc_empty_fb_page_post_comments_df, overwrite = TRUE)
