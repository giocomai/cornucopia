# Get Facebook page posts comments

For reference, see the [official
documentation](https://developers.facebook.com/docs/graph-api/reference/page-post/comments).

## Usage

``` r
cc_get_fb_page_post_comments(
  fb_post_id = NULL,
  cache = TRUE,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- fb_post_id:

  Facebook post identifier, must be a vector, or a data frame with an
  \`id\` column with Facebook post identifiers. Facebook page post
  identifiers can be retrieved with \[cc_get_fb_page_posts()\].

- cache:

  Defaults to \`TRUE\`.

## Value

A data frame with comments.
