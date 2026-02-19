# Extract url posted in comments

Extract url posted in comments

## Usage

``` r
cc_get_fb_page_post_comment_url(
  comments_df,
  posts_df = NULL,
  only_own_comments = TRUE,
  fb_page_id = NULL
)
```

## Arguments

- comments_df:

  A data frame created with \[cc_get_fb_page_post_comments()\].

- posts_df:

  A data frame created with \[cc_get_fb_page_posts()\].

## Value

A data frame, similar to \`comments_df\`, but with an additional
\`url_message\` column.
