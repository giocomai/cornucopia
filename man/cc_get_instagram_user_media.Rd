% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cc_get_instagram_user_media.R
\name{cc_get_instagram_user_media}
\alias{cc_get_instagram_user_media}
\title{Retrieve information about other users through `business_discovery`}
\usage{
cc_get_instagram_user_media(
  ig_username,
  media_fields = c("like_count", "comments_count", "caption", "media_product_type",
    "media_type", "media_url", "permalink", "thumbnail_url", "timestamp", "username"),
  max_pages = NULL,
  api_version = "v19.0",
  ig_user_id = NULL,
  fb_user_token = NULL
)
}
\arguments{
\item{ig_username}{A user name of an Instagram user.}

\item{media_fields}{Defaults to all fields publicly available through `business_discovery`.}

\item{max_pages}{Posts are returned in pages of 25 posts each. How many pages should be retrieved? By default, this will try to retrieve all posts.}
}
\description{
Consider that only information about posts of creative or business users may be available.
Given restrictions on the rate limit, you are likely to hit rate limits quite soon.
Wait one hour and try again.
}
