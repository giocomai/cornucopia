# Get files with visitors stats exported from LinkedIn

N.B. Only the "Metrics" sheet is processed, as other sheets give overall
statistics, not limited to the relevant time period.

## Usage

``` r
cc_get_linkedin_stats_visitors(path, page_name, export_csv = FALSE)
```

## Arguments

- path:

  Base path where all xls files exported from LinkedIn are stored.

- page_name:

  Name of the page. If unsure about the exact form, see the relevant
  column of \`cc_get_linkedin_stats_files()\`

- export_csv:

  Defaults to TRUE. If TRUE, exports visitors stats in a csv file in a
  folder with the same name as the base path, but with "\_processed"
  appended.

## Value

A data frame.
