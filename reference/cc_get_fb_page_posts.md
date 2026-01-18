# Get Facebook page post id and basic information that can be stored as strings

Find out what each of the fields effectively means in the [official
documentation](https://developers.facebook.com/docs/graph-api/reference/v24.0/page/feed).

Find out what each of the fields effectively means in the [official
documentation](https://developers.facebook.com/docs/graph-api/reference/v24.0/page/feed).

## Usage

``` r
cc_get_fb_page_posts(
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  max_pages = NULL,
  fields = cc_fb_page_post_fields[["fields"]],
  process_json = TRUE,
  cache = TRUE,
  only_cached = FALSE,
  wait = 0,
  fb_page_id = NULL,
  fb_page_token = NULL
)

cc_get_fb_page_posts(
  meta_api_version = cornucopia::cc_get_meta_api_version(),
  max_pages = NULL,
  fields = cc_fb_page_post_fields[["fields"]],
  process_json = TRUE,
  cache = TRUE,
  only_cached = FALSE,
  wait = 0,
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
  \`cc_fb_page_post_fields\[\["fields"\]\]\` for a full list and the
  [official documentation for more
  details](https://developers.facebook.com/docs/graph-api/reference/v24.0/page/feed).

  Expect caching to work consistently only if you leave this value
  unchanged. Consider disabling caching if you customise this parameter.

- process_json:

  Defaults to TRUE. If TRUE, fields returning objects (not strigs) are
  returned in list columns in the output data frame. If FALSE, they are
  returned as json-formatted strings, to be further processed.

- cache:

  Defaults to TRUE.

- only_cached:

  Defaults to FALSE. If TRUE, only data cached locally will be
  retrieved.

## Value

A data frame, with the same columns as \`cc_empty_fb_page_post_df\`;
each column in the returned data frame is of class character.

A data frame, with the same columns as \`cc_empty_fb_page_post_df\`;
each column in the returned data frame is of class character.

## Details

As some fields return objects that can be read as lists, rather than
simple strings, the data are cached locally as json. To have them
processed as lists, set \`process_json\` to TRUE.

As some fields return objects that can be read as lists, rather than
simple strings, the data are cached locally as json. To have them
processed as lists, set \`process_json\` to TRUE.

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
