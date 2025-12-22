## code to prepare `cc_empty_fb_page_post_df` dataset goes here

# https://developers.facebook.com/docs/graph-api/reference/v24.0/page/feed

cc_empty_fb_page_post_df <- tibble::tibble(
  created_time = character(),
  id = character(),
  permalink_url = character(),
  message = character(),
  full_picture = character(),
  icon = character(),
  is_hidden = character(),
  is_expired = character(),
  instagram_eligibility = character(),
  is_eligible_for_promotion = character(),
  promotable_id = character(),
  is_instagram_eligible = character(),
  is_popular = character(),
  is_published = character(),
  is_spherical = character(),
  parent_id = character(),
  status_type = character(),
  story = character(),
  subscribed = character(),
  sheduled_publish_time = character(),
  updated_time = character()
)

usethis::use_data(cc_empty_fb_page_post_df, overwrite = TRUE)
