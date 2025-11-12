# Upload to Google Sheets Metrics statistics exported from LinkedIn

Upload to Google Sheets Metrics statistics exported from LinkedIn

## Usage

``` r
cc_drive_upload_linkedin_stats_content(
  path,
  page_name,
  sheet_dribble = NULL,
  base_dribble = NULL,
  export_csv = FALSE
)
```

## Arguments

- path:

  Base path where all xls files exported from LinkedIn are stored.

- page_name:

  Name of the page. If unsure about the exact form, see the relevant
  column of \`cc_get_linkedin_stats_files()\`

- sheet_dribble:

  Dribble of the specific sheet where files should be uploaded.

- base_dribble:

  Dribble of the folder where the relevant sheet is expected to be.

- export_csv:

  Defaults to TRUE. If TRUE, exports content stats in a csv file in a
  folder with the same name as the base path, but with "\_processed"
  appended.
