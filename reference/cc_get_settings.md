# Retrieve settings for the session.

Typically set with \`cc_set()\`.

## Usage

``` r
cc_get_settings(
  meta_api_version = NULL,
  start_date = NULL,
  end_date = NULL,
  fb_user_token = NULL,
  fb_page_token = NULL,
  fb_page_id = NULL,
  fb_business_id = NULL,
  fb_ad_account_id = NULL,
  fb_product_catalog_id = NULL,
  fb_user_id = NULL,
  ig_user_id = NULL,
  ga_email = NULL,
  ga_property_id = NULL,
  woocommerce_api_version = NULL,
  woocommerce_username = NULL,
  woocommerce_password = NULL
)
```

## Arguments

- start_date:

  Nominally defaults to NULL, but effectively to 91 days before today.

- end_date:

  Nominally defaults to NULL, but effectively to yesterday.

## Value

A list of named elements.

## Examples

``` r
# \donttest{
if (interactive()) {
  dates_l <- cc_get_settings()
  dates_l
}
# }
```
