# Downloads media or previews of Facebook posts

Downloads media or previews of Facebook posts

## Usage

``` r
cc_download_facebook_media(
  posts_df = NULL,
  type = c("full_picture", "attachment"),
  path = NULL,
  wait = 1,
  ...
)
```

## Arguments

- posts_df:

  Defaults to \`NULL\`. If given, expected to be a data frame generated
  with \[cc_get_fb_page_posts()\].

- type:

  Defaults to "full_picture", type of media to download. Other options
  not yet implemented.

- path:

  Path to the folder where files will be downloaded; defaults to
  \`fb_full_picture\`, depending on \`type\`. If the path does not
  exist, it will be created.

- wait:

  Defaults to 1. Time to wait between downloading each file.

- ...:

  Passed to \[cc_get_fb_page_posts()\].

## Value

Nothing, used for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive()) {
   cc_download_instagram_media()
}
} # }
```
