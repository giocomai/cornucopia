# Process data frame with json columns and turn them into lists

Columns with names starting with \`json\_\` are assumed to contain json
as strings and will be processed. All the rest will be ignored. This
function is mostly used to process data cached locally and stored as a
json string in order to prevent database limitations. They are not
initially processed, as the structure of some data may vary
significantly across different cases. Used e.g. to process data cached
locally with \[cc_get_fb_page_posts()\].

## Usage

``` r
cc_process_json(df)
```

## Arguments

- df:

  A data frame, with columns starting with \`json\_\`, that are
  effectively character vectors with json-formatted data as strings,
  such as those generated with \[cc_get_fb_page_posts()\].

## Value

A data frame, with the same number of columns as the input. All columns
with names originally starting with \`json\_\` have been processed into
lists, and the prefix \`json\_\` removed from the column name.

## Examples

``` r
if (FALSE) { # \dontrun{
  posts_df <- cc_get_fb_page_posts()

  posts_df |>
   cc_process_json() |>
   tidyr::unnest(attachments)
} # }
```
