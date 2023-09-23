## code to prepare `cc_valid_metrics_ig_media_insights` dataset goes here

# https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights

cc_valid_metrics_ig_media_insights <- list(
  carousel_album = c(
    "impressions",
    "reach",
    "video_views",
    "saved",
    "total_interactions"
  ),
  photo_video = c(
    #    "total_interactions", # should work, but actually doesn't
    "impressions",
    "reach",
    "saved",
    "video_views"
  ),
  reels = c(
    "comments",
    "likes",
    "plays",
    "reach",
    "saved",
    "shares",
    "total_interactions"
  ),
  story = c(
    "impressions",
    "reach",
    "replies",
    "follows",
    "navigation",
    "profile_activity",
    "profile_visits",
    "shares",
    "total_interactions"
  ),
  posts = c(
    "impressions",
    "reach",
    "video_views",
    "likes",
    "comments",
    "shares",
    "saved",
    "total_interactions",
    "follows",
    "profile_activity",
    "profile_visits"
  )
)

usethis::use_data(cc_valid_metrics_ig_media_insights, overwrite = TRUE)
