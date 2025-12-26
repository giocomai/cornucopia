# Retrieve information about other users through \`business_discovery\`

Consider that only information about posts of creative of business users
may be available. Given restrictions on the rate limit, you are likely
to hit rate limits quite soon. Wait one hour and try again. See \`wait\`
and \`limit\` parameters for more options.

## Usage

``` r
cc_get_instagram_bd_user_media(
  ig_username,
  mode = c("update", "full", "only_cached"),
  fields = c("username", "timestamp", "like_count", "view_count", "comments_count",
    "caption", "media_product_type", "media_type", "media_url", "thumbnail_url",
    "permalink"),
  max_pages = NULL,
  wait = 0,
  limit = 80,
  update = TRUE,
  cache = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ig_user_id = NULL,
  fb_user_token = NULL
)
```

## Arguments

- ig_username:

  A user name of an Instagram user.

- mode:

  Defaults to "update", available options include "full". If set to
  "full", and some media have been previously retrieved, it tries to
  continue from the previous request as long as all available media have
  been retrieved. If set to "update", it retrieves the latest media,
  even if previously retrieved, to update relevant fields.

- fields:

  Defaults to all fields publicly available through
  \`business_discovery\`. See \[the
  documentation\](https://developers.facebook.com/docs/instagram-platform/reference/instagram-media)
  for other fields that may be available.

- max_pages:

  Posts are returned in pages of 25 posts each. How many pages should be
  retrieved? By default, this will try to retrieve all posts.

- wait:

  Defaults to zero. Time in seconds before each request to the API. If
  you make a very small number of queries, you can leave it to zero. If
  you make a even just a few dozens query, you'll hit API limits unless
  you set a wait time. Setting this to 300 (5 minutes) should slow
  things down just enough (but yes, this means you'll get 25 posts every
  five minutes, no more and no less).

- limit:

  Defaults to 80, meaning 80 three values determining rate limiting
  reaches at least 80 returns what it has collected so far. Set to NULL
  to ignore. For details, see \[the official
  documentation\](https://developers.facebook.com/docs/graph-api/overview/rate-limiting/).

- cache:

  Defaults to TRUE.

## Value

A data frame with the selected fields as columns, and a row for each
post of the selected Instagram account.

## Details

For details about rate limits, see \[this section of the
documentation\](https://developers.facebook.com/docs/graph-api/overview/rate-limiting).

\[More details about Business Discovery and relevant
permissions\](https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/business_discovery/).

In brief, necessary:

\- \`instagram_basic\` - \`instagram_manage_insights\` -
\`pages_read_engagement\` or \`pages_show_list\`

If the token is from a User whose Page role was granted via the Business
Manager, one of the following permissions is also required:

\- \`ads_management\` - \`pages_read_engagement\` -
\`business_management\`

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_instagram_bd_user_media(
  ig_username = "unitednations",
  max_pages = 3
)

# the following retrieves older posts, starting from where it left off
cc_get_instagram_bd_user_media(
  ig_username = "unitednations",
  mode = "full",
  max_pages = 3
)
} # }
```
