## code to prepare `cc_empty_instagram_media_df` dataset goes here

cc_empty_instagram_media_df <- tibble::tibble(
  ig_media_id = character(),
  ig_id = character(),
  username = character(),
  timestamp = character(),
  media_product_type = character(),
  media_type = character(),
  like_count = integer(),
  comments_count = integer(),
  caption = character(),
  is_comment_enabled = logical(),
  is_shared_to_feed = logical(),
  owner = character(),
  shortcode = character(),
  permalink = character(),
  media_url = character(),
  thumbnail_url = character(),
  timestamp_retrieved = character()
)

usethis::use_data(cc_empty_instagram_media_df, overwrite = TRUE)
