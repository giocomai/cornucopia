# Set settings and token for the session

Set settings and token for the session

## Usage

``` r
cc_set(
  start_date = NULL,
  end_date = NULL,
  fb_user_token = NULL,
  fb_page_token = NULL,
  fb_page_id = NULL,
  fb_business_id = NULL,
  fb_ad_account_id = NULL,
  fb_product_catalog_id = NULL,
  fb_user_id = NULL,
  ig_user_id = NULL,
  ga_email = NULL,
  ga_property_id = NULL
)
```

## Arguments

- start_date:

  Defaults to 91 days before today

- end_date:

  Defaults to yesterday.

- fb_user_token:

  Facebook user token different from page token. Can be retrieved with
  \[cc_get_fb_user_token()\] or \[cc_get_fb_long_user_token()\].

- fb_page_token:

  Facebook page token, different from the user token. Can be retrieved
  with \[cc_get_fb_page_token()\] or \[cc_get_fb_long_page_token()\].

- fb_page_id:

  Facebook page identifier. Can be retrieved with
  \[cc_get_fb_managed_pages()\].

- fb_business_id:

  Facebook business id. For details on how to find it, see
  <https://www.facebook.com/business/help/1181250022022158>

- ga_email:

  E-mail addressed associated with relevant Google Analytics account,
  passed to \`googleAnalyticsR::ga_auth()\`

- ga_property_id:

  Google Analytics property identifier. Find it with
  \`googleAnalyticsR::ga_account_list("ga4")\`.

## Value

A list of named elements.

## Examples

``` r
# \donttest{
if (interactive()) {
  dates_l <- cc_set()
  dates_l
}
# }
```
