# Return a tibble with details about all the stats files exported from LinkedIn Pages

Provide a path to a local folder where a bunch of files with names such
as "pagename_followers_1684688073420.xls" are stored. The path will be
scanned recursively and a tidy data framre returned, including columns
with the name of the page, the type of stats included in each file, as
well as the date when the data have been exported.

## Usage

``` r
cc_get_linkedin_stats_files(path)
```

## Arguments

- path:

  A path to a folder to be scanned recursively
