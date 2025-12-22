# Get Facebook user id and name, as well as other options fields

For details, see:
<https://developers.facebook.com/docs/graph-api/reference/user/>

## Usage

``` r
cc_get_fb_user(
  fb_user_token = NULL,
  fields = c("id", "name"),
  format = "data.frame"
)
```

## Format

Defaults to "data.frame". If "list", a list is returned instead; useful
e.g. when the "picture" field is requested.

## Arguments

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

## Value

By default, a data frame with one row and two character columns, "name"
and "id". Customisable with the \`format\` argument.

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_fb_user()
} # }
```
