# Get a long-lived page acess token for Facebook

For details, see
<https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived/>

## Usage

``` r
cc_get_fb_long_page_token(
  fb_user_id = NULL,
  fb_user_token = NULL,
  api_version = "v22.0"
)
```

## Arguments

- fb_user_id:

  App-scoped user id. This can be retrieved with \`cc_get_fb_user()\`

- fb_user_token:

  Must be a long-lived user token. This can be retrieved with
  \`cc_get_fb_long_user_token()\`.

## Value

A data frame with long-lived access tokens to all available pages.

## Details

You should use as input a long-lived user access token. Long-lived Page
access token do not have an expiration date and only expire or are
invalidated under certain conditions.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  cc_get_fb_long_page_token(
    fb_user_id = "your_fb_user_id_here",
    fb_user_token = "your_long_term_token_here"
  )
}
} # }
```
