## code to prepare `cc_empty_instagram_ig_bd_users_df` dataset goes here

cc_empty_instagram_ig_bd_users_df <- tibble::tibble(
  id = character(),
  username = character()
)

usethis::use_data(cc_empty_instagram_ig_bd_users_df, overwrite = TRUE)
