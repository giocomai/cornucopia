% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cc_get_instagram_media.R
\name{cc_api_get_instagram_media}
\alias{cc_api_get_instagram_media}
\title{Get information about a single media directly from the API. Mostly used
internally.}
\usage{
cc_api_get_instagram_media(
  ig_media_id,
  fields = cc_valid_fields_instagram_media_v,
  api_version = "v19.0",
  token = NULL
)
}
\arguments{
\item{ig_media_id}{Instagram media identifier, must be a vector of length 1.
A list of identifiers for your account can be retrieved with
`cc_get_instagram_media_id()`.}

\item{api_version}{Defaults to "v18.0".}
}
\description{
Get information about a single media directly from the API. Mostly used
internally.
}
