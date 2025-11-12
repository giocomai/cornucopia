# Get a long-lived user access token for Facebook

For details, see
<https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived/>

## Usage

``` r
cc_get_fb_long_user_token(
  fb_user_token = NULL,
  fb_app_id = NULL,
  fb_app_secret = NULL,
  api_version = "v22.0"
)
```

## Value

A character vector of length one, with the long-loved user access token.

## Details

You should use as input a short-lived user access token. In future
calls, you can then routinely use your newly aquired long-lived user
access token, which should generally last about 60 days.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  cc_get_fb_long_user_token(
    fb_user_token = "your_short_term_token_here",
    fb_app_id = "your_fb_app_id_here",
    fb_app_secret = "your_fb_app_secret_here"
  )
}
} # }
```
