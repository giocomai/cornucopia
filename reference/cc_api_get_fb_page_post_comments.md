# Get information about a comments from the API. Mostly used internally.

See the official documentation for reference:
<https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts>

For reference, see the [official
documentation](https://developers.facebook.com/docs/graph-api/reference/page-post/comments).

## Usage

``` r
cc_api_get_fb_page_post_comments(
  fb_post_id,
  cache = TRUE,
  cache_connection = NULL,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
)

cc_api_get_fb_page_post_comments(
  fb_post_id,
  cache = TRUE,
  cache_connection = NULL,
  update = TRUE,
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  fb_page_id = NULL,
  fb_page_token = NULL
)
```

## Arguments

- fb_post_id:

  Facebook post identifier, must be a vector of length 1. A list of
  identifiers for a given Facebook page can be retrieved with
  \[cc_get_fb_page_posts()\].

- cache:

  Defaults to \`TRUE\`.

- metric:

  Metrics to be retrieved. Consider that depending on the media type,
  different media types are effectively available. Requesting the wrong
  metrics will cause an error. Defaults to NULL. If left to NULL,
  metrics will be chosen based on the media type. See the official
  documentation for reference:
  <https://developers.facebook.com/docs/graph-api/reference/insights/#page-posts>

## Value

A data frame with comments for a given post.
