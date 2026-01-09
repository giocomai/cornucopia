# Get information about a single media directly from the API. Mostly used internally.

See the official documentation for reference:
<https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts>

## Usage

``` r
cc_api_get_fb_page_post_insights(
  fb_post_id,
  metric = cornucopia::cc_valid_fields_fb_post_insights,
  period = "lifetime",
  cache = TRUE,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- fb_post_id:

  Instagram media identifier, must be a vector of length 1. A list of
  identifiers for your account can be retrieved with
  \`cc_get_fb_page_posts()\`.

- metric:

  Metrics to be retrieved. Consider that depending on the media type,
  different media types are effectively available. Requesting the wrong
  metrics will cause an error. Defaults to NULL. If left to NULL,
  metrics will be chosen based on the media type. See the official
  documentation for reference:
  <https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts>

- cache:

  Defaults to TRUE.
