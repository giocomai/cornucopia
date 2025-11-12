# Reads locally stored dated files, typically generated with \`cc_get_fb_ads_by_date\`

Reads locally stored dated files, typically generated with
\`cc_get_fb_ads_by_date\`

## Usage

``` r
cc_read_fb_ads_by_date(
  path = "fb_ads_by_date_rds",
  start_date = NULL,
  end_date = NULL
)
```

## Arguments

- path:

  Path to dated files

- start_date:

  Defaults to NULL. If given, only files retrieved on this date or later
  are included. Input should be of date class, or on the YYYY-MM-DD
  format.

- end_date:

  Defaults to NULL. If given, only files retrieved on this date or
  sooner are included. Input should be of date class, or on the
  YYYY-MM-DD format.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive()) {
  cc_read_fb_ads_by_date()
}
} # }
```
