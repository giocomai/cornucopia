## code to prepare `cc_valid_metrics_ig_media_insights` dataset goes here

# https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights

cc_valid_metrics_ig_media_insights <- list(
  carousel = c("carousel_album_engagement",
               "carousel_album_impressions",
               "carousel_album_reach",
               "carousel_album_saved",
               "carousel_album_video_views"),
  photo_video = c("engagement",
                  "impressions",
                  "reach",
                  "saved",
                  "video_views"),
  reels = c("comments",
            "likes",
            "plays",
            "reach",
            "saved",
            "shares",
            "total_interactions"),
  story = c("exits",
            "impressions",
            "reach",
            "replies",
            "taps_forward",
            "taps_back",
            "follows",
            "navigation",
            "profile_activity",
            "profile_visits",
            "shares",
            "total_interactions"),
  posts = c("impressions",
            "reach",
            "video_views",
            "likes",
            "comments",
            "shares",
            "engagement",
            "saved",
            "total_interactions",
            "follows",
            "profile_activity",
            "profile_visits"
)
)

usethis::use_data(cc_valid_metrics_ig_media_insights, overwrite = TRUE)
