# Retrieve information about a user through Instagram's business discovery

This function allows you to retrieve basic information about an
Instagram account you are not associated with, as long as they are a
business account.

## Usage

``` r
cc_get_instagram_bd_user(
  ig_username,
  fields = c("id", "ig_id", "username", "name", "biography", "website",
    "followers_count", "follows_count", "media_count", "profile_picture_url"),
  api_version = "v22.0",
  ig_user_id = NULL,
  fb_user_token = NULL
)
```

## Arguments

- ig_username:

  A user name of an Instagram user.

- fields:

  Defaults to all fields publicly available through
  \`business_discovery\`. See \[the
  documentation\](https://developers.facebook.com/docs/instagram-platform/reference/instagram-media)
  for other fields that may be available.

## Details

\[More details about Business Discovery and relevant
permissions\](https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/business_discovery/).

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  # e.g. to retrieve information about the Instagram account of the United Nations
  cc_get_instagram_bd_user(ig_username = "unitednations")
}
} # }
```
