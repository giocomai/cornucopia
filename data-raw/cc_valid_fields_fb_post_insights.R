## code to prepare `cc_valid_fields_fb_post_insights` dataset goes here
cc_valid_fields_fb_post_insights <- c(
  "post_clicks",
  "post_clicks_by_type",
  "post_impressions",
  "post_impressions_unique",
  "post_impressions_paid",
  "post_impressions_paid_unique",
  "post_impressions_fan",
  "post_impressions_fan_unique",
  "post_impressions_organic",
  "post_impressions_organic_unique",
  "post_impressions_viral",
  "post_impressions_viral_unique",
  "post_impressions_nonviral",
  "post_impressions_nonviral_unique",
  "post_reactions_like_total",
  "post_reactions_love_total",
  "post_reactions_wow_total",
  "post_reactions_haha_total",
  "post_reactions_sorry_total",
  "post_reactions_anger_total",
  "post_reactions_by_type_total",
  "post_media_view"
)


## Video
video <- c(
  "post_video_avg_time_watched",
  "post_video_complete_views_organic",
  "post_video_complete_views_organic_unique",
  "post_video_complete_views_paid",
  "post_video_complete_views_paid_unique",
  "post_video_views_organic",
  "post_video_views_organic_unique",
  "post_video_views_paid",
  "post_video_views_paid_unique",
  "post_video_length",
  "post_video_views",
  "post_video_views_unique",
  "post_video_views_autoplayed",
  "post_video_views_clicked_to_play",
  "post_video_views_15s",
  "post_video_views_60s_excludes_shorter",
  "post_video_views_10s",
  "post_video_views_10s_unique",
  "post_video_views_10s_autoplayed",
  "post_video_views_10s_clicked_to_play",
  "post_video_views_10s_organic",
  "post_video_views_10s_paid",
  "post_video_views_10s_sound_on",
  "post_video_views_sound_on",
  "post_video_view_time",
  "post_video_view_time_organic"
)

video_detailed_graph <- c(
  "post_video_retention_graph",
  "post_video_retention_graph_clicked_to_play",
  "post_video_retention_graph_autoplayed",
  "post_video_view_time_by_age_bucket_and_gender",
  "post_video_view_time_by_region_id",
  "post_video_views_by_distribution_type",
  "post_video_view_time_by_distribution_type",
  "post_video_view_time_by_country_id"
)


usethis::use_data(cc_valid_fields_fb_post_insights, overwrite = TRUE)
