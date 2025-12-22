# Get information about a single media directly from the API. Mostly used internally.

See the official documentation for reference:
<https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights>

## Usage

``` r
cc_api_get_instagram_media_insights(
  ig_media_id,
  metrics = NULL,
  media_type = NULL,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  ig_user_id = NULL,
  fb_user_token = NULL
)
```

## Arguments

- ig_media_id:

  Instagram media identifier, must be a vector of length 1. A list of
  identifiers for your account can be retrieved with
  \`cc_get_instagram_media_id()\`.

- metrics:

  Metrics to be retrieved. Consider that depending on the media type,
  different media types are effectively available. Requesting the wrong
  metrics will cause an error. Defaults to NULL. If left to NULL,
  metrics will be chosen based on the media type. See the official
  documentation for reference:
  <https://developers.facebook.com/docs/instagram-api/reference/ig-media/insights>

- media_type:

  Media type. Valid values include "IMAGE", "VIDEO", "REELS", and
  "CAROUSEL_ALBUM". Defaults to NULL. If not given, it will be retrieved
  with \`cc_get_instagram_media\`. Ignored if \`metrics\` explicitly
  given.

- meta_api_version:

  Defaults to the latest API at the time this package was last updated.
  Currently, this corresponds to api version 24.0.

- ig_user_id:

  Instagram user id, typically composed of 17 digits. Not to be confused
  with legacy Instagram account id.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].
