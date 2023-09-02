
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cornucopia <a href='https://github.com/giocomai/cornucopia'><img src='man/figures/logo.png' align="right" style="height:320px;" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of cornucopia is to facilitate reporting on sponsored and
organic activities on Facebook, Instagram, and LinkedIn (currently), as
well as to estimate and visualise the result of marketing funnels (long
term).

## Why `cornucopia`?

For you all marketing folks, a cornucopia is like a funnel that keeps on
giving. Also known as the “[horn of
plenty](https://en.wikipedia.org/wiki/Cornucopia)”, it’s basically
really your wildest dream: a funnel that endlessly overflows with
abundance.

Why is this package called `cornucopia`? Because…

**This package will automagically turn your every funnel into a
cornucopia!**\*

\*Of course not, but I couldn’t resist including an impossibly bold
claim in this marketing-focused package.

## Installation

You can install the development version of cornucopia with:

``` r
remotes::install_github("giocomai/cornucopia")
```

## Meta / Facebook / Instagram

In order to get data out of the Meta ecosystem through APIs, you will
need to create an app in their

### Settings

You can you use `cc_set()` to set start and end dates to be used
throughout the analysis, as well as tokens that will then be loaded
automatically as needed by all other `cornucopia` functions.

``` r
dates_l <- cc_set(
  start_date = "2023-01-01",
  end_date = Sys.Date() - 1,
  fb_user_token = "looong_string"
)


dates_l
```

You can get your token from your app page:
<https://developers.facebook.com/apps/>

### Sponsored

For the time being, `cornucopia` relies on
[`fbRads`](https://github.com/daroczig/fbRads) to get data about
sponsored campaigns and store them locally.

``` r
token <- "looooooooooong_string"

account <- "00000000000000000"

fbad_init(
  accountid = account,
  token = token
)

ads_df <- cc_get_fb_ads()
```

Notice that if you ask for a lengthy period, you may hit the API query
limit. The error message is however not helpful, as it apparently
complains about `fields`. Just wait and try again after a few hours: all
downloaded data are by default stored in a local folder and nothing will
lost, queries will be made only for missing data.

If you’re hitting the API limits, you can set the `only_cached`
parameter to TRUE, so you can proceed with your analysis with the data
you have until you’ll be able to download more data.

``` r
ads_df <- cc_get_fb_ads(only_cached = TRUE)
```

Notice that you can customise the fields to retrieve and that not all
fields can be asked at the same time. See the embedded list
`cc_valid_fields_ad_insights` for list of valid fields, divided by broad
categories (this subdivision has been made by the package author, not by
Facebook itself). Caching of retrieved contents by type of fields will
be addedt to future versions.

Not all ad-related information, however, can be retrieved through this
endpoint. For example, if you want details about the creatives used in
an ad, you will first need to make queries to retrieve the `creative_id`
associated with each ad ([see documentation of this
endpoint](https://developers.facebook.com/docs/marketing-api/reference/adgroup/adcreatives/)),
and only then query the [ad creative
endpoint](https://developers.facebook.com/docs/marketing-api/reference/ad-creative/)
to retrieve relevant information about the creative.

The first step of this process, i.e. retrieving `creative_id` can be
achieved by passing a vector of `ad_id` to
`cc_get_fb_ad_creatives_id()`. Data will be cached locally by default,
assuming creatives will mostly be added at the time when the ad is
created.

### Instagram

As for all things related to Meta’s API, you will need an app, and a
valid token with all the needed permissions (not having the right
permissions is the most frequent problem you’ll find, so when
troubleshooting, take it from there).

So first set your `ig_user_id` and your token.

``` r
cc_set(
  ig_user_id = "00000000000000000", # probably about 17 digits, not the legacy Instagram id
  fb_user_token = "loooong_string"
) # the regular token, not the "page token"
```

And you can get some basic information about your profile:

``` r
cc_get_instagram_user()
```

Or just some specific fields:

``` r
cc_get_instagram_user(fields = c("username", "followers_count"))
```

In order to get detailed information about each of your posts, you first
need to know their `ig_media_id`. You can get this id for all of your
posts with the following command:

``` r
cc_get_instagram_media_id()
```

Be mindful that this may make many queries, as Instagram gives the
result in batches of 25… if you have thousands of media, it may take
some time. Data are however cached locally by default.

You can then pass the resulting `ig_media_id` to
`cc_get_instagram_media()` to get more information about a given
Instagram post.

``` r
cc_get_instagram_media()
```

### Facebook pages

\[to do\]

## LinkedIn

LinkedIn does not allow for exporting statistics about pages or ads
systematically, if not by using one of a very small number of
ridiculously expensive third party services.

This complicated the independent processing of the data, as well as
their inclusion in third party dashboard.

To deal with both of these issues, `cornucopia` includes a set of
functions that facilitates:

- processing files with statistics exported from LinkedIn
- store them locally in a consistent manner
- keep them updated in a set of Google Sheets, in order to facilitate
  their integration with services such as Looker Studio

The user just needs to download relevant files and store them in a
folder, without paying attention to anything else, really. Files for
more than one page can be included in the same folder and no special
attention needs to be dedicated to the time period included:
`cornucopia` will always strive to include data for the longest possible
period, always preferring the most recent data available. For this
reason, it is usually easiest to export data about the last 365 days,
and let this package deal with the rest.

Export files for all sorts of a statics from your LinkedIn page. They
will have file names such as “pagename_followers_1684688073420.xls”.
Throw all of them in a folder, that we’ll call “LinkedIn_stats”.

You can then retrieve some basic information about these files using:

``` r
cc_get_linkedin_stats_files(path = "LinkedIn_stats")
```

This allows to see when a file was exported, what is the name of the
page, and what type of statistics it includes: all of this information
can be gathered from the file name.

Each of the statistics types exported from LinkedIn has its own data
format, and indeed there is little consistency in these files, if not
for the ridiculous insistence on including dates in the ridiculous US
date format (month-day-year), no matter where you are in the world.

Anyway… we can now move on to the specific functions for each type of
statistics. The following functions parse all relevant files and merge
the data preferring the most recently downloaded data over older files
(this may be irrelevant in many cases, but may well have some impact in
statistics associated with a given post).

``` r
followers_df <- cc_get_linkedin_stats_followers(
  path = "LinkedIn_stats",
  page = "example-page"
)
```

Once we have these data, we can of course process them as we usually
would. But for the sake of this post, we are imagining a workflow that
requires us to upload these files to a Google Sheet, in order to
facilitate data retrieval through Google Looker Studio.

We can do this manually, but, of course, we’d much rather use a set of
convenience functions that will process data and upload them
automatically to the same Google Sheet, updating the dataset if one was
previously uploaded.

``` r
cc_drive_upload_linkedin_stats_followers(
  path = "LinkedIn_stats",
  page_name = "example-page"
)

cc_drive_upload_linkedin_stats_content(
  path = "LinkedIn_stats",
  page_name = "example-page"
)

cc_drive_upload_linkedin_stats_visitors(
  path = "LinkedIn_stats",
  page_name = "example-page"
)
```

## Disclaimer

I despise ad-tech, but I’ve got work to do.

## License

`cornucopia` is released under a MIT license.
