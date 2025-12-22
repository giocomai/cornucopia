# Get Facebook page insights

Official documentation:
<https://developers.facebook.com/docs/graph-api/reference/v24.0/insights>
For avaialable metrics, see:
<https://developers.facebook.com/docs/graph-api/reference/v24.0/insights#availmetrics>

## Usage

``` r
cc_get_fb_page_insights(
  metric = c("page_impressions"),
  start_date = NULL,
  end_date = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  cache = TRUE,
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- metric:

  Defaults to \`page_impressions\`.

- start_date:

  Defaults to 91 days before today

- end_date:

  Defaults to yesterday.

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

- fb_page_id:

  Facebook page identifier. Can be retrieved with
  \[cc_get_fb_managed_pages()\].

- fb_page_token:

  Facebook page token, different from the user token. Can be retrieved
  with \[cc_get_fb_page_token()\] or \[cc_get_fb_long_page_token()\].
