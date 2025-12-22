# Get managed pages, including name, page token, and id

Be mindful of the permissions associated with the current user token:
you will probably need "pages_show_list", and, if pages are managed
through a business manger, "business_management". If you don't get any
response, the problem is most likely related to permissions, so try
adding more permissions as relevant.

## Usage

``` r
cc_get_fb_managed_pages(
  fields = c("id", "name"),
  fb_user_id = NULL,
  fb_user_token = NULL,
  api_version = "v22.0"
)
```

## Arguments

- fields:

  Defaults to \`c("id", "name")\`. Include "access_token" in order to
  retrieve you Facebook page access token.

- fb_user_id:

  Facebook user id. Defaults to NULL, can be set with \`cc_set()\`. Can
  be retrieved with \`cc_get_fb_user()\`.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

- api_version:

  Defaults to "v21.0".

## Value

A data frame (a tibble), with as many columns as fields (by default,
\`id\` and \`name\`).

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_fb_managed_pages()
} # }
```
