# Retrieve identifier of Instagram user

Mostly used internally for consistent storing and caching.

## Usage

``` r
cc_get_instagram_bd_user_basic(
  ig_username,
  cache = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ig_user_id = NULL,
  fb_user_token = NULL
)
```

## Arguments

- ig_username:

  Instagram username of an Instagram business user.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  # e.g. to retrieve information about the Instagram account of the United Nations
  cc_get_instagram_bd_user_basic(ig_username = "unitednations")
}
} # }
```
