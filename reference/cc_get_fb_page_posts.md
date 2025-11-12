# Get Facebook page post id and basic information that can be stored as strings

Find out what each of the fields effectively means in the official
documentation:
<https://developers.facebook.com/docs/graph-api/reference/v24.0/page/feed>

## Usage

``` r
cc_get_fb_page_posts(
  api_version = "v24.0",
  max_pages = NULL,
  fields = names(cc_empty_fb_page_post_df),
  cache = TRUE,
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- max_pages:

  Posts are returned in pages of 25 posts each. How many pages should be
  retrieved? By default, this will try to retrieve all posts.

- fields:

  Lists of fields which return data consistently, see
  \`names(cc_empty_fb_page_post_df)\` for a full list and the official
  documentation for more details
  <https://developers.facebook.com/docs/graph-api/reference/v21.0/page/feed>.
  Expect caching to work consistently only if you leave this value
  unchanged. Consider disabling caching if you customise this parameter.

- cache:

  Defaults to TRUE.

## Value

A data frame, with the sale columns as \`cc_empty_fb_page_post_df\`;
each column in the returned data frame is of class character.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive) {
  fb_page_token <- cc_get_fb_page_token(
    fb_user_id = cc_get_fb_user(),
    page_name = "My example page"
  )

  cc_set(fb_page_token = fb_page_token)
  posts_df <- cc_get_fb_page_posts()
  posts_df
}
} # }
```
