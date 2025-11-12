# Get details about Facebook ads

Caches data in the folder \`fb_ads_by_date_rds\` in the current working
directory.

## Usage

``` r
cc_get_fb_ads(
  start_date = NULL,
  end_date = NULL,
  only_cached = FALSE,
  fields = c("campaign_name", "campaign_id", "adset_name", "adset_id", "ad_name",
    "ad_id", "objective", "account_currency", "spend", "actions", "action_values",
    "cost_per_action_type", "cost_per_unique_action_type", "conversions",
    "cost_per_conversion", "conversion_rate_ranking", "cpc", "cpm", "cpp", "ctr",
    "frequency", "reach"),
  fb_ad_account_id = NULL
)
```

## Arguments

- only_cached:

  Defaults to FALSE. If TRUE, only pre-cached files within the given
  date range are loaded; no new calls to the API are made and reliably
  works offline.

## Value

A data frame with an extensive number of fields, some presented as
nested data frames.

## Details

See also \`cc_get_fb_ads_by_date()\` for customisation of fields.

For valid fields, see:
<https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/>

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_fb_ads()
} # }
```
