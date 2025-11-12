# Get information about a Facebook catalog products

Data are not cached locally.

## Usage

``` r
cc_get_fb_products(
  fb_product_catalog_id = NULL,
  fields = cc_valid_fields_fb_product,
  api_version = "v22.0",
  max_pages = NULL,
  token = NULL
)
```

## Value

A data frame. Some columns include nested data.

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_fb_products()
} # }
```
