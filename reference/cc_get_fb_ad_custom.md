# Get custom stats about an ad (currently not functional)

https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-stats/

## Usage

``` r
cc_get_fb_ad_custom(
  fields = "reach",
  breakdowns = "frequency_value",
  ad_id = NULL,
  start_date = NULL,
  end_date = NULL,
  only_cached = FALSE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  cache = TRUE,
  ad_account_id = NULL,
  fb_user_token = NULL
)
```

## Details

attribution window
https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/
