# Get information about a single media directly from the API. Mostly used internally.

Get information about a single media directly from the API. Mostly used
internally.

## Usage

``` r
cc_api_get_instagram_media(
  ig_media_id,
  fields = cornucopia::cc_valid_fields_instagram_media_v,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_user_token = NULL
)
```

## Arguments

- ig_media_id:

  Instagram media identifier, must be a vector of length 1. A list of
  identifiers for your account can be retrieved with
  \`cc_get_instagram_media_id()\`.

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].
