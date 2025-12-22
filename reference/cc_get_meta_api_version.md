# Retrieve version of Meta API.

Retrieve version of Meta API.

## Usage

``` r
cc_get_meta_api_version(meta_api_version = NULL)
```

## Arguments

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

## Examples

``` r
cc_get_meta_api_version()
#> [1] "v24.0"

cc_get_meta_api_version("23.0")
#> [1] "23.0"

cc_set(meta_api_version = "24.0")

cc_get_meta_api_version()
#> [1] "24.0"
```
