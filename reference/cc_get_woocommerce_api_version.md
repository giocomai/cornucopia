# Retrieve version of Woocommerce API.

Retrieve version of Woocommerce API.

## Usage

``` r
cc_get_woocommerce_api_version(woocommerce_api_version = NULL)
```

## Examples

``` r
cc_get_woocommerce_api_version()
#> [1] "v3"

cc_get_woocommerce_api_version("v3")
#> [1] "v3"

cc_set(woocommerce_api_version = "v2")

cc_get_woocommerce_api_version()
#> [1] "v2"

cc_set(woocommerce_api_version = "v3")
```
