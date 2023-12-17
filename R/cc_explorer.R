#' Run the Shiny Application
#'
#' @param custom_head_html Chunk of code to be included in the app's `<head>`.
#'   This can be used, e.g., for custom analytics snippets. The default value,
#'   `<meta name="referrer" content="no-referrer" />` asks the browser not to
#'   include the source website when following links to external websites.
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#' @inheritParams cc_set
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
cc_explorer <- function(
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
    custom_head_html = '<meta name="referrer" content="no-referrer" />',
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...) {
  with_golem_options(
    app = shinyApp(
      ui = cc_explorer_ui,
      server = cc_explorer_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(
      start_date = start_date,
      end_date = end_date,
      fb_user_token = fb_user_token,
      fb_page_token = fb_page_token,
      fb_page_id = fb_page_id,
      fb_business_id = fb_business_id,
      fb_ad_account_id = fb_ad_account_id,
      fb_product_catalog_id = fb_product_catalog_id,
      fb_user_id = fb_user_id,
      ig_user_id = ig_user_id,
      custom_head_html = custom_head_html,
      ...
    )
  )
}
