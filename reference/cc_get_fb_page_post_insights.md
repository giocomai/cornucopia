# Get Facebook page posts insights

For reference, see the [official
documentation](https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts).

## Usage

``` r
cc_get_fb_page_post_insights(
  fb_post_id = NULL,
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

  Facebook page post identifier, must be a vector of length 1. A list of
  identifiers for your Facebook page can be retrieved with
  \[cc_get_fb_page_posts()\].

- metric:

  Metrics to be retrieved. Consider that depending on the media type,
  different media types are effectively available. Requesting the wrong
  metrics will cause an error. Defaults to \`NULL\`. If left to
  \`NULL\`, metrics will be chosen based on the media type. See [the
  official
  documentation](https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts)
  for reference.

- cache:

  Defaults to \`TRUE\`.

## Value

A data frame, with the folowing columns: "fb_post_id", "metric_title",
"metric_description", "metric_name", "metric_value_name",
"metric_value", "period", and "timestamp_retrieved".

## Details

N.B. Even if not detailed in the documentation "page_impressions\*"
metrics have been deprecated on 15 November 2025. See [the official
update](https://developers.facebook.com/docs/platforminsights/page/deprecated-metrics).

Defaults to Lifetime period for each post.

Cache not yet working.
