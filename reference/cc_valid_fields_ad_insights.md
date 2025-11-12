# A list with all valid fields for the Ad Insights Marketing API

As all fields cannot be requested at the same time, they are grouped
here according to their thematic scope in a named list. As this division
is not formalised in the official API, the named list has been liberally
built by the package author. As the actual contents of some fiels is not
immediately obvious nor clearly described in the official documentation
they may be misplaced until they are fully tested. Fields may be
repeated when relevant. \`ad_id\` is included in all lists as it can be
used for matching.

## Usage

``` r
cc_valid_fields_ad_insights
```

## Format

\## \`cc_valid_fields_ad_insights\` A named list with all valid fields
for Ad Insights.

- about_the_account:

  Retrieves information about the ad account. If you separate clearly
  your ad account, you probably don't need to request this information
  with every call.

- about_the_ad:

  Retrieves information about a given ad. Logically, these should need
  to be requested only once per ad and, e.g. not on a daily basis as
  they should remain unchanged for each ad.

- about_the_ad_timing:

  Retrieves information about the timing of a given ad, when it started,
  ended, etc. These also need to be requested only once per ad, but may
  need to be updated while the ad is still running.

## Source

\<https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/\>
