# Retrieve base url of Woocommerce API.

Typically it follows a pattern such as:
\`https://www.example.com/wp-json/wc/\`. Do not include the API version
(e.g. \`v3\`), which is set separately.

## Usage

``` r
cc_get_woocommerce_base_url(woocommerce_base_url = NULL)
```

## Value

The base url as a character vector of length 1.

## Examples

``` r
cc_get_woocommerce_base_url()
#> [1] ""

cc_get_woocommerce_base_url("https://www.example.com/wp-json/wc/")
#> [1] "https://www.example.com/wp-json/wc/"

cc_set(woocommerce_base_url = "https://www.example.com/custom/wp-json/wc/")

cc_get_woocommerce_base_url()
#> [1] "https://www.example.com/custom/wp-json/wc/"
```
