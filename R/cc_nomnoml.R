#' Show ad campaign structure in a nomnmonl graph
#'
#' @param ads_df
#' @param direction Defaults to "right". Can be "down". Passed to `nomnoml`.
#' @param drop_vertical_bar Defaults to FALSE. If TRUE, replaces vertical bar
#'   (which in `nomnoml` can be used to separate a block in subsections) with
#'   "-".
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
cc_nomnoml <- function(ads_df,
                       direction = "right",
                       drop_vertical_bar = FALSE,
                       ...) {
  nodes_df <- dplyr::bind_rows(
    dplyr::distinct(
      .data = ads_df,
      id = campaign_id,
      text = campaign_name
    ),
    dplyr::distinct(
      .data = ads_df,
      id = adset_id,
      text = adset_name
    ),
    dplyr::distinct(
      .data = ads_df,
      id = ad_id,
      text = ad_name
    )
  )


  if (drop_vertical_bar == TRUE) {
    nodes_df <- nodes_df |>
      dplyr::mutate(text = stringr::str_replace_all(
        string = text,
        pattern = stringr::fixed("|"),
        replacement = "-"
      ))
  }



  edges_df <- dplyr::bind_rows(
    dplyr::distinct(
      .data = ads_df,
      from = campaign_id,
      to = adset_id
    ),
    dplyr::distinct(
      .data = ads_df,
      from = adset_id,
      to = ad_id
    )
  ) |>
    dplyr::mutate(association = "-")

  nomnomlgraph::nn_graph(
    nodes = nodes_df,
    edges = edges_df,
    direction = direction,
    ...
  )
}
