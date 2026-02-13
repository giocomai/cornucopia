# Get identifiers of all media published on a profile

Get identifiers of all media published on a profile

## Usage

``` r
cc_get_instagram_media_id(
  ig_user_id = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_user_token = NULL,
  max_pages = NULL,
  cache = TRUE
)
```

## Arguments

- ig_user_id:

  Instagram user id, typically composed of 17 digits. Not to be confused
  with legacy Instagram account id.

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

- max_pages:

  Defaults to \`NULL\`. If not given, it retrieves the number of media
  and calculates max number of pages needed. Hard-coded max number of
  pages at 1000.

## Value

A tibble with one column named \`ig_media_id\` with identifiers of
Instagram media.
