# Get Facebook ad creatives id for each ad id

See:
https://developers.facebook.com/docs/marketing-api/reference/adgroup/adcreatives/

## Usage

``` r
cc_get_fb_ad_creatives_id(
  ad_id = NULL,
  ad_account_id = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  cache = TRUE,
  fb_user_token = NULL
)
```

## Value

A data frame with three character columns: \`ad_id\`, \`creative_id\`,
and \`timestamp_retrieved\`
