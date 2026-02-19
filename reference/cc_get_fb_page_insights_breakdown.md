# Get Facebook page insights with breakdown

Currently apparently only applies to Page media view. For reference, see
the [official
documentation](https://developers.facebook.com/docs/graph-api/reference/v24.0/insights#page-media-view).

## Usage

``` r
cc_get_fb_page_insights_breakdown(
  metric = "page_media_view",
  breakdowns = c("is_from_followers", "is_from_ads"),
  start_date = NULL,
  end_date = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  cache = TRUE,
  only_cached = FALSE,
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- metric:

  Defaults to \`page_media_view\`.

- breakdowns:

  Only one breakdown at a time, only the first one is processed. Only
  accepted values: \`is_from_ads\`, \`is_from_followers\`.

- start_date:

  Defaults to 91 days before today

- end_date:

  Defaults to yesterday.

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

- cache:

  Defaults to \`TRUE\`.

- only_cached:

  Defaults to \`FALSE\`. If \`TRUE\`, only data cached locally will be
  retrieved.

- fb_page_id:

  Facebook page identifier. Can be retrieved with
  \[cc_get_fb_managed_pages()\].

- fb_page_token:

  Facebook page token, different from the user token. Can be retrieved
  with \[cc_get_fb_page_token()\] or \[cc_get_fb_long_page_token()\].

## Value

A data frame with breakdowns.
