#' Get files with visitors stats exported from LinkedIn
#'
#' N.B. Only the "Metrics" sheet is processed, as other sheets give overall statistics, not limited to the relevant time period.
#'
#' @param path Base path where all xls files exported from LinkedIn are stored.
#' @param page_name Name of the page. If unsure about the exact form, see the relevant column of `cc_get_linkedin_stats_files()`
#' @param export_csv Defaults to TRUE. If TRUE, exports visitors stats in a csv file in a folder with the same name as the base path, but with "_processed" appended.
#'
#' @return A data frame.
#' @export
#'
#' @examples
cc_get_linkedin_stats_visitors <- function(path,
                                           page_name,
                                           export_csv = FALSE) {
  current_files_df <- cc_get_linkedin_stats_files(path = path) |>
    dplyr::filter(
      type == "visitors",
      page == page_name
    ) |>
    dplyr::arrange(dplyr::desc(datetime))

  current_sheet <- "Visitor metrics"

  visitors_df <- purrr::reduce(
    .x = current_files_df$path,
    .init = NULL,
    .f = function(df,
                  current_file) {
      if (is.null(df)) {
        readxl::read_xls(
          path = current_file,
          sheet = current_sheet,
          skip = 0
        ) |>
          dplyr::mutate(Date = lubridate::mdy(Date))
      } else {
        dplyr::bind_rows(
          df,
          readxl::read_xls(
            path = current_file,
            sheet = current_sheet,
            skip = 0
          ) |>
            dplyr::mutate(Date = lubridate::mdy(Date)) |>
            dplyr::filter(Date < min(df$Date))
        )
      }
    }
  ) |>
    dplyr::arrange(dplyr::desc(Date))


  if (export_csv == TRUE) {
    processed_stats_folder <- stringr::str_c(
      path,
      "_processed"
    )

    fs::dir_create(processed_stats_folder, page_name)

    visitors_file_name <- fs::path(
      processed_stats_folder,
      page_name,
      stringr::str_c(
        page_name,
        "_",
        stringr::str_to_lower(current_sheet) |>
          stringr::str_replace_all(
            pattern = "[[:space:]]",
            replacement = "_"
          ),
        ".csv"
      ) |>
        fs::path_sanitize()
    )


    readr::write_csv(
      x = visitors_df,
      file = visitors_file_name
    )
    cli::cli_inform("Folloer stats stored in {.path {visitors_file_name}}")
  }

  visitors_df
}


#' Upload to Google Sheets Visitor metrics statistics exported from LinkedIn
#'
#' @param sheet_dribble Dribble of the specific sheet where files should be uploaded.
#' @param base_dribble Dribble of the folder where the relevant sheet is expected to be.
#'
#' @inheritParams cc_get_linkedin_stats_visitors
#'
#' @return
#' @export
#'
#' @examples
cc_drive_upload_linkedin_stats_visitors <- function(path,
                                                    page_name,
                                                    sheet_dribble = NULL,
                                                    base_dribble = NULL,
                                                    export_csv = FALSE) {
  visitors_df <- cc_get_linkedin_stats_visitors(
    path = path,
    page_name = page_name,
    export_csv = export_csv
  )

  if (is.null(sheet_dribble)) {
    if (is.null(base_dribble)) {
      processed_stats_folder <- stringr::str_c(
        path,
        "_processed"
      )

      processed_stats_page_folder <- fs::dir_create(
        processed_stats_folder,
        page_name
      )

      base_folder_dribble_file <- fs::path(
        processed_stats_page_folder,
        stringr::str_c(
          page_name,
          "_dribble.rds"
        )
      )

      if (fs::file_exists(base_folder_dribble_file)) {
        base_folder_dribble <- readRDS(file = base_folder_dribble_file)
      } else {
        base_folder_dribble <- googledrive::drive_mkdir(
          name = page_name,
          path = ""
        )

        saveRDS(base_folder_dribble,
          file = base_folder_dribble_file
        )
      }

      current_sheets_available_df <- googledrive::drive_ls(
        path = base_folder_dribble,
        recursive = FALSE
      )
      sheet_name <- stringr::str_c(page_name, "_visitors")

      if (sheet_name %in% current_sheets_available_df$name) {
        visitors_dribble <- current_sheets_available_df |>
          dplyr::filter(name == sheet_name)
      } else {
        visitors_dribble <- googlesheets4::gs4_create(
          name = sheet_name,
          sheets = "Visitor metrics"
        )

        googledrive::drive_mv(
          file = visitors_dribble,
          path = base_folder_dribble
        )
      }
    }
  } else {
    visitors_dribble <- sheet_dribble
  }


  googlesheets4::sheet_write(
    data = visitors_df,
    ss = visitors_dribble,
    sheet = "Visitor metrics"
  )
}
