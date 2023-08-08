% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cc_set.R
\name{cc_set}
\alias{cc_set}
\title{Set default start and end dates}
\usage{
cc_set(
  start_date = NULL,
  end_date = NULL,
  fb_user_token = NULL,
  fb_page_token = NULL,
  ig_user_id = NULL
)
}
\arguments{
\item{start_date}{Defaults to 91 days before today}

\item{end_date}{Defaults to yesterday.}
}
\value{
A list with two named elements of class "Date", `start_date` and `end_date`
}
\description{
Set default start and end dates
}
\examples{
\donttest{
if (interactive()) {
  dates_l <- cc_set()
  dates_l
}
}

}