# Retrieve and store locally either orders or client items

Retrieve and store locally either orders or client items

## Usage

``` r
cc_get_woocommerce_json_by_pagination(
  pages = NULL,
  type = c("orders", "customers"),
  wait = 1,
  woocommerce_base_url = cornucopia::cc_get_woocommerce_base_url(),
  woocommerce_api_version = cornucopia::cc_get_woocommerce_api_version(),
  woocommerce_username = cornucopia::cc_get_settings()[["woocommerce_username"]],
  woocommerce_password = cornucopia::cc_get_settings()[["woocommerce_password"]],
  woocommerce_cache_folder = cornucopia::cc_get_settings()[["woocommerce_cache_folder"]]
)
```

## Arguments

- pages:

  Defaults to \`NULL\`, or all available pages. If given, it downloads
  at most the given number of pages.

- type:

  Defaults to "orders". Expected to be either "order" or "client".

- wait:

  Defaults to 1. Seconds to wait between calls to the API.

## Value

Nothing, only caches locally data.

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_woocommerce_json(
  id = c(100:110),
  type = "orders")
} # }
```
