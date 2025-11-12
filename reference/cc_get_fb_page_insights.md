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
  api_version = "v24.0",
  cache = TRUE,
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- fb_page_token:
