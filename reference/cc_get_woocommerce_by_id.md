# Retrieve and extract in a data frame either orders or client items

Retrieve and extract in a data frame either orders or client items

## Usage

``` r
cc_get_woocommerce_by_id(
  id = NULL,
  type = c("orders", "customers"),
  metadata = FALSE,
  selected_metadata = NULL,
  only_cached = FALSE,
  overwrite = FALSE,
  wait = 1,
  woocommerce_base_url = cornucopia::cc_get_woocommerce_base_url(),
  woocommerce_api_version = cornucopia::cc_get_woocommerce_api_version(),
  woocommerce_username = cornucopia::cc_get_settings()[["woocommerce_username"]],
  woocommerce_password = cornucopia::cc_get_settings()[["woocommerce_password"]],
  woocommerce_cache_folder = cornucopia::cc_get_settings()[["woocommerce_cache_folder"]]
)
```

## Arguments

- id:

  An identifier of either order or client, according to what is set in
  \`type\`. Coerced to a character vector.

- type:

  Defaults to "orders". Expected to be either "order" or "client".

- metadata:

  Defaults to \`FALSE\`. If \`TRUE\`, processed metadata. Set to
  \`FALSE\`, as not fit for generic use.

- selected_metadata:

  Defaults to \`NULL\`. A character vector with the name of the metadata
  fields to keep, e.g. \`c("\_wwpp_order_type")\`.

- overwrite:

  Defaults to \`FALSE\`. If \`TRUE\`, it re-downloads data for the
  requested id. If \`FALSE\`, it downloads items only if they have not
  been previously cached.

- wait:

  Defaults to 1. Seconds to wait between calls to the API.

## Value

Returns main data retrieved from the API as a data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_woocommerce_by_id(
  id = c(100:110),
  type = "orders")
} # }
```
