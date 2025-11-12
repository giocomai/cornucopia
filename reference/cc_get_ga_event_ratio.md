# Calculate the ratio of two Google Analytics events

Calculate the ratio of two Google Analytics events

## Usage

``` r
cc_get_ga_event_ratio(
  events,
  rolling = FALSE,
  rolling_before = 7,
  rolling_after = 7,
  rolling_period = "day",
  rolling_complete = FALSE,
  start_date = NULL,
  end_date = NULL,
  ga_email = NULL,
  ga_property_id = NULL
)
```

## Arguments

- events:

  A character vector of length 2, such as \`c("session_start",
  "purchase")\` to calculate the ratio between these two events.

- rolling:

  If TRUE, calculates a rolling mean over the number of periods (by
  default, days) set with \`rolling_before\` and \`rolling_after\`.

- rolling_complete:

  Defaults to FALSE. If TRUE, rolling mean is calculated only for
  periods that are fully available.

- start_date:

  Defaults to 91 days before today

- end_date:

  Defaults to yesterday.

- ga_email:

  E-mail addressed associated with relevant Google Analytics account,
  passed to \`googleAnalyticsR::ga_auth()\`

- ga_property_id:

  Google Analytics property identifier. Find it with
  \`googleAnalyticsR::ga_account_list("ga4")\`.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  cc_get_ga_event_ratio(c("session_start", "purchase"))
}
} # }
```
