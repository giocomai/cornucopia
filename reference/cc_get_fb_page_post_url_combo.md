# Retrieve urls posted in a Facebook page, no matter if as attachment, in the message of a post, or in a comment

Retrieve urls posted in a Facebook page, no matter if as attachment, in
the message of a post, or in a comment

## Usage

``` r
cc_get_fb_page_post_url_combo(posts_with_url_df, comments_with_url_df)
```

## Arguments

- posts_with_url_df:

  A data frame created with \[cc_get_fb_page_post_url()\].

- comments_with_url_df:

  A data frame created with \[cc_get_fb_page_post_comment_url()\].

## Value

A data frame, with url and reference to Facebook post identifier.
