% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cc_explorer.R
\name{cc_explorer}
\alias{cc_explorer}
\title{Run the Shiny Application}
\usage{
cc_explorer(
  start_date = cc_get_settings()[["start_date"]],
  end_date = cc_get_settings()[["end_date"]],
  fb_user_token = cc_get_settings()[["fb_user_token"]],
  fb_page_token = cc_get_settings()[["fb_page_token"]],
  fb_page_id = cc_get_settings()[["fb_page_id"]],
  fb_business_id = cc_get_settings()[["fb_business_id"]],
  fb_ad_account_id = cc_get_settings()[["fb_ad_account_id"]],
  fb_product_catalog_id = cc_get_settings()[["fb_product_catalog_id"]],
  fb_user_id = cc_get_settings()[["fb_user_id"]],
  ig_user_id = cc_get_settings()[["ig_user_id"]],
  ig_user_df = NULL,
  custom_head_html = "<meta name=\\"referrer\\" content=\\"no-referrer\\" />",
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
)
}
\arguments{
\item{start_date}{Defaults to 91 days before today}

\item{end_date}{Defaults to yesterday.}

\item{fb_user_token}{Facebook user token (not a page token).}

\item{fb_business_id}{Facebook business id. For details on how to find it,
see \url{https://www.facebook.com/business/help/1181250022022158}}

\item{custom_head_html}{Chunk of code to be included in the app's `<head>`.
This can be used, e.g., for custom analytics snippets. The default value,
`<meta name="referrer" content="no-referrer" />` asks the browser not to
include the source website when following links to external websites.}

\item{onStart}{A function that will be called before the app is actually run.
This is only needed for \code{shinyAppObj}, since in the \code{shinyAppDir}
case, a \code{global.R} file can be used for this purpose.}

\item{options}{Named options that should be passed to the \code{runApp} call
(these can be any of the following: "port", "launch.browser", "host", "quiet",
"display.mode" and "test.mode"). You can also specify \code{width} and
\code{height} parameters which provide a hint to the embedding environment
about the ideal height/width for the app.}

\item{enableBookmarking}{Can be one of \code{"url"}, \code{"server"}, or
\code{"disable"}. The default value, \code{NULL}, will respect the setting from
any previous calls to  \code{\link[shiny:enableBookmarking]{enableBookmarking()}}. See \code{\link[shiny:enableBookmarking]{enableBookmarking()}}
for more information on bookmarking your app.}

\item{uiPattern}{A regular expression that will be applied to each \code{GET}
request to determine whether the \code{ui} should be used to handle the
request. Note that the entire request path must match the regular
expression in order for the match to be considered successful.}

\item{...}{arguments to pass to golem_opts.
See `?golem::get_golem_options` for more details.}
}
\description{
Run the Shiny Application
}
