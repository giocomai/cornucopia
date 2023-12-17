#' Create a card to be used in dashboard or shiny app with basic information
#' about the Instagram account
#' 
#' @inheritParams cc_get_instagram_user
#'
#' @return
#' @export
#' @examples
#' \dontrun{
#' if (interactive) {
#'   cc_ui_instagram_user_card()
#' }
#' }
cc_ui_instagram_user_card <- function(ig_user_df = NULL,
                                      ig_user_id = NULL,
                                      fb_user_token = NULL) {
  if (is.null(ig_user_df)) {
    ig_user_df <- cc_get_instagram_user(
      ig_user_id = ig_user_id,
      fb_user_token = fb_user_token
    )
  }

  bslib::card(
    bslib::card_header(
      htmltools::p(
        ig_user_df[["name"]],
        htmltools::br(),
        htmltools::a(stringr::str_c("@", ig_user_df[["username"]]),
          href = stringr::str_c(
            "https://www.instagram.com/",
            ig_user_df[["username"]]
          ),
          target = "_blank"
        )
      ),
      htmltools::img(
        src = ig_user_df[["profile_picture_url"]],
        style = "width:64px;height:64px;"
      ),
      class = "d-flex justify-content-between"
    ),
    bslib::card_body(
      htmltools::p(
        htmltools::strong("Followers Instagram:"),
        scales::number(ig_user_df[["followers_count"]])
      )
    )
  )
}
