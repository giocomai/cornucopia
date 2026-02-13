## code to prepare `cc_empty_instagram_media_insights` dataset goes here

# https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights#breakdown

cc_empty_instagram_media_insights <- list(
  video = tibble::tibble(
    ig_media_id = character(),
    # impressions = numeric(),
    reach = numeric(),
    views = numeric(),
    saved = numeric(),
    total_interactions = numeric(),
    timestamp_retrieved = character()
  ),
  image = tibble::tibble(
    ig_media_id = character(),
    # impressions = numeric(),
    reach = numeric(),
    views = numeric(),
    saved = numeric(),
    total_interactions = numeric(),
    timestamp_retrieved = character()
  ),
  reels = tibble::tibble(
    ig_media_id = character(),
    comments = numeric(),
    likes = numeric(),
    views = numeric(),
    reach = numeric(),
    saved = numeric(),
    shares = numeric(),
    total_interactions = numeric(),
    timestamp_retrieved = character()
  ),
  carousel_album = tibble::tibble(
    ig_media_id = character(),
    # impressions = numeric(),
    reach = numeric(),
    views = numeric(),
    saved = numeric(),
    total_interactions = numeric(),
    timestamp_retrieved = character()
  )
)

usethis::use_data(cc_empty_instagram_media_insights, overwrite = TRUE)
