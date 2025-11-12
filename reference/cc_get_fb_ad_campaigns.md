# Get all campaigns for the current ad account / legacy

For details on fields, see:
https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/

## Usage

``` r
cc_get_fb_ad_campaigns(
  fields = cc_valid_fields_ad_campaign_group_v,
  api_version = "v22.0",
  fb_ad_account_id = NULL,
  max_pages = NULL,
  fb_user_token = NULL,
  cache = TRUE,
  update = TRUE
)
```

## Arguments

- fields:

  A character vector of fields to retrieve. Defaults to all valid fields
  that return a single value, see:
  \`cc_valid_fields_ad_campaign_group_v\`. Currently only default fields
  supported when caching.

## Details

It currently returns all fields that return a single value,
\`cc_valid_fields_ad_campaign_group_v\`

For reference, these are the fields that are always present for all
campaigns:
"id,name,created_time,updated_time,start_time,stop_time,objective,status"

Cache updating currently suboptimal.

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_fb_ad_campaigns()
} # }
```
