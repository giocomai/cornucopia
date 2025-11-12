# Get Facebook ads by date and store them locally

Get Facebook ads by date and store them locally

## Usage

``` r
cc_get_fb_ads_by_date(
  date,
  fields = c("campaign_name", "campaign_id", "adset_name", "adset_id", "ad_name",
    "ad_id", "objective", "account_currency", "spend", "actions", "action_values",
    "cost_per_action_type", "cost_per_unique_action_type", "conversions",
    "cost_per_conversion", "conversion_rate_ranking", "cpc", "cpm", "cpp", "ctr",
    "frequency", "reach"),
  fb_ad_account_id = NULL
)
```

## Arguments

- date:

  A vector of dates.
