## code to prepare `cc_valid_fields_instagram_media_v` dataset goes here

cc_valid_fields_instagram_media_v <- c(
  "id",
  "ig_id",
  "username",
  "timestamp",
  "caption",
  "media_product_type",
  "media_type",
  "like_count",
  "comments_count",
  "is_comment_enabled",
  "is_shared_to_feed",
  "owner",
  "shortcode",
  "permalink",
  "media_url",
  "thumbnail_url"
)

usethis::use_data(cc_valid_fields_instagram_media_v, overwrite = TRUE)
