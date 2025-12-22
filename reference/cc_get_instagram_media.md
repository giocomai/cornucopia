# Get details about a given Instagram post based on its ig_media_id

It retrieves the requested fields from the APIs and introduces a few
adjustments:

## Usage

``` r
cc_get_instagram_media(
  ig_media_id = NULL,
  fields = cc_valid_fields_instagram_media_v,
  api_version = "v22.0",
  ig_user_id = NULL,
  update = TRUE,
  cache = TRUE,
  fb_user_token = NULL
)
```

## Arguments

- ig_media_id:

  Instagram media identifier. A list of identifiers for your account can
  be retrieved with \`cc_get_instagram_media_id()\`. If left to NULL, a
  full list is automatically retrieved.

- api_version:

  Defaults to "v21.0".

- ig_user_id:

  Instagram user id, typically composed of 17 digits. Not to be confused
  with legacy Instagram account id.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

## Details

\- it always include the media id, in a column named \`ig_media_id\` -
if the field \`owner\` is included, it outputs the result as a character
vector (if more than one owner, separated by ;) - it adds a
\`timestamp_retrieved\` column, with ISO 8601-formatted creation date in
UTC - it ensures that the output always included all requested fields,
if they are valid; e.g. \`is_shared_to_feed\` and \`media_url\` may be
omitted by the API (see documentation) but this function always includes
the relevant column (and returns a NA value if no value is given) - all
valid fields for the given API endpoint are always requested and cached
locally; only requested fields are effectively returned (but
\`ig_media_id\` and \`timestamp_retrieved\` are always included as first
and last column)

For details, see:
https://developers.facebook.com/docs/instagram-api/reference/ig-media

## Examples

``` r
if (FALSE) { # \dontrun{
cc_get_instagram_media()
} # }
```
