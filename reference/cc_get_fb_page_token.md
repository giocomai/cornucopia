# Get Facebook page token

Get Facebook page token

## Usage

``` r
cc_get_fb_page_token(
  fb_user_id = NULL,
  page_id = NULL,
  page_name = NULL,
  fb_user_token = NULL
)
```

## Arguments

- fb_user_id:

  Facebook used id. If not known, can be retrieved with
  \`cc_get_fb_user()\`.

- page_id:

  Exact page id. See \`cc_get_fb_managed_pages()\` for pages you have
  access to.

- page_name:

  Exact page name. See \`cc_get_fb_managed_pages()\` for pages you have
  access to.

- token:

  User token.

## Value

A character vector of length one with the Facebook page token.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive()){
 cc_get_fb_page_token(
  fb_user_id = cc_get_fb_user(),
  page_name = "My example page"
 )
}
} # }
```
