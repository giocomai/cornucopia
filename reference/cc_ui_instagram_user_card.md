# Create a card to be used in dashboard or shiny app with basic information about the Instagram account

Create a card to be used in dashboard or shiny app with basic
information about the Instagram account

## Usage

``` r
cc_ui_instagram_user_card(
  ig_user_df = NULL,
  ig_user_id = NULL,
  fb_user_token = NULL
)
```

## Arguments

- ig_user_id:

  Instagram user id, typically composed of 17 digits. Not to be confused
  with legacy Instagram account id.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  cc_ui_instagram_user_card()
}
} # }
```
