# Get information about your Facebook product catalogs

See the relevant page in the documentation for available fields and more
details
https://developers.facebook.com/docs/marketing-api/reference/product-catalog

## Usage

``` r
cc_get_fb_owned_product_catalogs(
  fb_business_id = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fields = c("id", "business", "commerce_merchant_settings", "da_display_settings",
    "default_image_url", "fallback_image_url", "feed_count", "is_catalog_segment",
    "name", "product_count", "vertical"),
  token = NULL
)
```

## Arguments

- fb_business_id:

  Facebook business id. For details on how to find it, see
  <https://www.facebook.com/business/help/1181250022022158>

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

- fields:

  Defaults to all available.

- token:

  Facebook user token (not a page token).

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_fb_owned_product_catalogs()
} # }
```
