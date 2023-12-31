% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cc_get_fb_page_token.R
\name{cc_get_fb_page_token}
\alias{cc_get_fb_page_token}
\title{Get Facebook page token}
\usage{
cc_get_fb_page_token(
  fb_user_id = NULL,
  page_id = NULL,
  page_name = NULL,
  fb_user_token = NULL
)
}
\arguments{
\item{fb_user_id}{Facebook used id. If not known, can be retrieved with `cc_get_fb_user()`.}

\item{page_id}{Exact page id. See `cc_get_fb_managed_pages()` for pages you have access to.}

\item{page_name}{Exact page name. See `cc_get_fb_managed_pages()` for pages you have access to.}

\item{token}{User token.}
}
\value{
A character vector of length one with the Facebook token.
}
\description{
Get Facebook page token
}
\examples{
cc_get_fb_page_token(
  fb_user_id = cc_get_fb_user(),
  page_name = "My example page"
)
}
