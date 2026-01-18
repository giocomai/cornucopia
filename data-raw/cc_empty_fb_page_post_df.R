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
  updated_time = character(),
  json_actions = character(),
  json_admin_creator = character(),
  allowed_advertising_objects = character(),
  json_application = character(),
  json_attachments = character(),
  backdated_time = character(),
  json_call_to_action = character(),
  can_reply_privately = character(),
  child_attachments = character(),
  json_feed_targeting = character(),
  json_from = character(),
  json_to = character(),
  json_message_tags = character(),
  json_place = character(),
  json_privacy = character(),
  json_properties = character(),
  json_shares = character(),
  json_story_tags = character(),
  json_targeting = character(),
  json_video_buying_eligibility = character(),
  timestamp_retrieved = character()
)


cc_fb_page_post_fields <- list(
  fields = names(cc_empty_fb_page_post_df) |> stringr::str_remove_all("json_"),
  character_fields = names(cc_empty_fb_page_post_df)[stringr::str_starts(
    names(cc_empty_fb_page_post_df),
    "json_",
    negate = TRUE
  )],
  list_fields = names(cc_empty_fb_page_post_df)[stringr::str_starts(
    names(cc_empty_fb_page_post_df),
    "json_"
  )] |>
    stringr::str_remove_all("json_")
)

usethis::use_data(cc_empty_fb_page_post_df, overwrite = TRUE)

usethis::use_data(cc_fb_page_post_fields, overwrite = TRUE)
