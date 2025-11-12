# Get total Facebook ad spending per day by campaign and as a rolling average

Get total Facebook ad spending per day by campaign and as a rolling
average

## Usage

``` r
cc_get_fb_ad_spend_totals_by_day_by_campaign(
  ads_df = NULL,
  start_date = NULL,
  end_date = NULL,
  before = 3,
  after = 3
)
```

## Arguments

- ads_df:

  A data frame, such as the one retrieved with \`cc_get_fb_ads()\`

- start_date:

  Defaults to 91 days before today

- end_date:

  Defaults to yesterday.

- before:

  Defaults to 3. Days to keep before the given day for calculating
  rolling averages.

- after:

  Defaults to 3. Days to keep after the given day for calculating
  rolling averages.
