# Get Facebook page posts insights

For reference, see:
https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts
defaults to Lifetime period for each post.

## Usage

``` r
cc_get_fb_page_post_insights(
  fb_post_id = NULL,
  metrics = cc_valid_fields_fb_post_insights,
  cache = TRUE,
  update = TRUE,
  api_version = "v24.0",
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- fb_page_token:

## Details

Cache not yet working.
