# Takes all action results for all days when an ad is active

For action breakdowns, see [the official Marketing API, Insights API
documentation](https://developers.facebook.com/docs/marketing-api/insights/breakdowns/).

## Usage

``` r
cc_get_fb_ad_actions_by_day(
  ad_id = NULL,
  type = "actions",
  action_breakdowns = NULL,
  cache = FALSE,
  only_cached = FALSE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ad_account_id = NULL,
  fb_user_token = NULL,
  max_pages = NULL
)
```

## Arguments

- only_cached:

  Defaults to FALSE. If TRUE, only data cached locally will be
  retrieved.

## Details

Draft: caching disabled by default as only partly functional; Not yet
fully tested with ads running longer than 25 days
