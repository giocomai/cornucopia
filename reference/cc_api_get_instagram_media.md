# Get information about a single media directly from the API. Mostly used internally.

Get information about a single media directly from the API. Mostly used
internally.

## Usage

``` r
cc_api_get_instagram_media(
  ig_media_id,
  fields = cc_valid_fields_instagram_media_v,
  api_version = "v22.0",
  fb_user_token = NULL
)
```

## Arguments

- ig_media_id:

  Instagram media identifier, must be a vector of length 1. A list of
  identifiers for your account can be retrieved with
  \`cc_get_instagram_media_id()\`.

- api_version:

  Defaults to "v21.0".

- fb_user_token:

  Facebook user token (not a page token).
