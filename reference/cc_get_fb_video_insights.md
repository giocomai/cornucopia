# Get Facebook video insights

For reference, see:
https://developers.facebook.com/docs/graph-api/reference/video/video_insights/
defaults to Lifetime period for each video

## Usage

``` r
cc_get_fb_video_insights(
  fb_video_id,
  metrics = cc_valid_fields_fb_video_insights,
  cache = TRUE,
  update = TRUE,
  api_version = "v22.0",
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- fb_page_token:
