# Extract urls included in posts shared on Facebook pages

Extracts both urls explicitly shared, as well as those included in the
message of the post.

## Usage

``` r
cc_get_fb_page_post_url(posts_df = NULL, ...)
```

## Arguments

- posts_df:

  A data frame created with \[cc_get_fb_page_posts()\].

## Value

A data frame, including an \`url_share\` column (with urls explicitly
shared), \`url_message\` column for url shared in the main text of the
post, and \`url_all\`, combining the previous two and dropping NA.

## Examples

``` r
if (FALSE) { # \dontrun{
url_all_df <- cc_get_fb_page_posts(only_cached = TRUE, process_json = TRUE) |>
  cc_get_fb_page_post_url()

url_all_df |>
  tidyr::unnest("url_all") |>
  dplyr::select(c("created_time", "id", "url_all"))
  } # }
```
