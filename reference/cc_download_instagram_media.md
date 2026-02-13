# Downloads Instagram media or thumbnails

Downloads Instagram media or thumbnails

## Usage

``` r
cc_download_instagram_media(
  media_df = NULL,
  type = c("media", "thumbnail"),
  path = NULL,
  wait = 1,
  ...
)
```

## Arguments

- media_df:

  Defaults to \`NULL\`. If given, expected to be a data frame generated
  with \[cc_get_instagram_media()\].

- type:

  Defaults to "media", type of media to download. The only alternative
  valid value is "thumbnail".

- path:

  Path to the folder where files will be downloaded; defaults to either
  \`ig_media\` or \`ig_thumbnail\`, depending on \`type\`. If the path
  does not exist, it will be created.

- wait:

  Defaults to 1. Time to wait between downloading each file.

- ...:

  Passed to \[cc_get_instagram_media()\].

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
