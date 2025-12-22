# Get information about your Instagram user

If you need to retrieve your Instagram user id, consider
\`cc_get_instagram_user_id()\`.

## Usage

``` r
cc_get_instagram_user(
  ig_user_id = NULL,
  api_version = "v22.0",
  fields = c("id", "ig_id", "username", "name", "biography", "website",
    "followers_count", "follows_count", "media_count", "profile_picture_url"),
  fb_user_token = NULL
)
```

## Arguments

- ig_user_id:

  Instagram user id, typically composed of 17 digits. Not to be confused
  with legacy Instagram account id.

- api_version:

  Defaults to "v21.0".

- fields:

  Defaults to all available (except "shopping_product_tag_eligibility",
  which requires dedicated permissions). Consider reducing if you don't
  have all relevant permissions.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

## Value

A data frame (a tibble), with a column for id, plus as many columns as
the requested fields.

## Details

See the relevant page in the documentation for available fields and more
details
https://developers.facebook.com/docs/instagram-api/reference/ig-user

Look in particular at the permissions requirements. If you have issues,
consider dropping \`shopping_product_tag_eligibility\` from the fields,
as it requires additional permissions.

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_instagram_user()
} # }
```
