#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
cc_explorer_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    tags$head(shiny::HTML(golem::get_golem_options("custom_head_html"))),
    # Your application UI logic
    bslib::page_navbar(
      theme = bslib::bs_theme(),
      title = "cornucopia",
      sidebar = bslib::sidebar(
        shiny::dateRangeInput(
          inputId = "date_range",
          label = NULL,
          start = Sys.Date() - 6,
          weekstart = 1
        ),
      ),
      bslib::nav_panel(
        title = "Overview",
        p("[to do]")
      ),
      bslib::nav_panel(
        title = "Facebook organic",
        bslib::layout_column_wrap(
          width = 1 / 2,
          bslib::card(bslib::card_header("[TO DO]")),
          bslib::card(bslib::card_header("[TO DO]"))
        ),
      ),
      bslib::nav_panel(
        title = "Instagram organic",
        bslib::layout_column_wrap(
          width = 1 / 2,
          bslib::card(bslib::card_header("[TO DO]")),
          cc_ui_instagram_user_card(
            ig_user_df = golem::get_golem_options("ig_user_df"),
            ig_user_id = golem::get_golem_options("ig_user_id"),
            fb_user_token = golem::get_golem_options("fb_user_token")
          )
        ),
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(ext = "png"),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "cornucopia"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
