# Get frequency distribution

For details, see the [official documentation on Insights
breakdowns](https://developers.facebook.com/docs/marketing-api/insights/breakdowns).

## Usage

``` r
cc_get_fb_ad_frequency_distribution(
  ad_id = NULL,
  date_preset = c("maximum", "last_7d", "last_30d", "today", "yesterday", "this_month",
    "last_month", "this_quarter", "maximum", "data_maximum", "last_3d", "last_7d",
    "last_14d", "last_28d", "last_30d", "last_90d", "last_week_mon_sun",
    "last_week_sun_sat", "last_quarter", "last_year", "this_week_mon_today",
    "this_week_sun_today", "this_year"),
  output = c("tibble", "barchart", "list"),
  start_date = NULL,
  end_date = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ad_account_id = NULL,
  fb_user_token = NULL
)
```

## Arguments

- ad_id:

  Indentifier of a an \`ad_id\`, \`adset_id\`, or \`campaign_id\`.

- date_preset:

  Defaults to "maximum". Available values include "last_7d", "last_30d",
  and similar, as described in the [official API
  documentation](https://developers.facebook.com/docs/marketing-api/insights/breakdowns).
  N.B. This is ignored if both \`start_date\` and \`end_date\` are
  given.

- start_date:

  The beginning date for the period to be considered. Both
  \`start_date\` and \`end_date\` must be given. If either is ignored,
  \`preset\` takes precedence.

- end_date:

  The end date for the period to be considered. Both \`start_date\` and
  \`end_date\` must be given. If either is ignored, \`preset\` takes
  precedence.
