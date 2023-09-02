## code to prepare `cc_valid_fields_ad_insights` dataset goes here
# https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/

## cannot ask all together, hence need to be separated

cc_valid_fields_ad_insights <- list(
  about_the_account = c( # about the account
    "account_id",
    "account_name",
    "account_currency"
  ),
  about_the_ad = c( # about the ad

    "campaign_name",
    "campaign_id",
    "adset_name",
    "adset_id",
    "ad_name",
    "ad_id",
    "objective",
    "optimization_goal"
  ),
  about_the_ad_timing = c(
    "ad_id",
    "created_time",
    "updated_time",
    "date_start",
    "date_stop"
  ),
  asset_related = c(
    "ad_id",
    "title_asset",
    "ad_format_asset",
    "image_asset",
    "media_asset",
    "video_asset",
    "body_asset",
    "description_asset",
    "rule_asset"
  ),


  # money
  spend = c(
    "ad_id",
    "spend",
    "social_spend"
  ),

  # actions and conversions
  actions = c(
    "ad_id",
    "actions",
    "action_values",
    "cost_per_action_type",
    "cost_per_unique_action_type",
    "ad_click_actions",
    "impressions",
    "ad_impression_actions",
    "clicks",
    "cost_per_ad_click",
    "cost_per_unique_click",
    "inline_link_clicks",
    "cost_per_inline_link_click",
    "cost_per_unique_inline_link_click",
    "inline_link_click_ctr",
    "inline_post_engagement",
    "outbound_clicks",
    "outbound_clicks_ctr",
    "cost_per_unique_outbound_click",
    "cost_per_inline_post_engagement",
    "cost_per_one_thousand_ad_impression",
    "cost_per_outbound_click",
    "video_30_sec_watched_actions"
  ),
  conversions = c(
    "ad_id",
    "conversions",
    "cost_per_conversion",
    "cost_per_unique_conversion",
    "conversion_values",
    "coarse_conversion_value",
    "conversion_rate_ranking",
    "cpc",
    "cpm",
    "cpp",
    "ctr",
    "website_ctr",
    "frequency",
    "frequency_value",
    "reach"
  ),

  ## Viewing
  canvas_views = c(
    "ad_id",
    "canvas_avg_view_percent",
    "canvas_avg_view_time"
  ),
  video_views = c(
    "ad_id",
    "cost_per_15_sec_video_view",
    "cost_per_2_sec_continuous_video_view",
    "cost_per_thruplay",
    "video_avg_time_watched_actions",
    "video_continuous_2_sec_watched_actions",
    "video_play_actions",
    "video_play_curve_actions",
    "video_p25_watched_actions",
    "video_p50_watched_actions",
    "video_p75_watched_actions",
    "video_p95_watched_actions",
    "video_p100_watched_actions",
    "video_play_retention_0_to_15s_actions",
    "video_play_retention_20_to_60s_actions",
    "video_play_retention_graph_actions",
    "video_time_watched_actions",
    "full_view_impressions",
    "full_view_reach"
  ),



  ## Time

  hourly_stats = c(
    "ad_id",
    "hourly_stats_aggregated_by_advertiser_time_zone",
    "hourly_stats_aggregated_by_audience_time_zone"
  ),


  ## Instant experience
  instant_experience = c(
    "ad_id",
    "instant_experience_clicks_to_open",
    "instant_experience_clicks_to_start",
    "instant_experience_outbound_clicks",
    "interactive_component_tap"
  ),

  ## Catalog

  catalog = c(
    "ad_id",
    "product_id",
    "catalog_segment_actions",
    "catalog_segment_value",
    "catalog_segment_value_mobile_purchase_roas",
    "catalog_segment_value_omni_purchase_roas",
    "catalog_segment_value_website_purchase_roas",
    "user_segment_key",
    "mobile_app_purchase_roas",
    "purchase_roas",
    "website_purchase_roas",
    "converted_product_quantity",
    "converted_product_value"
  ),


  # Ad recall

  ad_recall = c(
    "ad_id",
    "estimated_ad_recall_rate_lower_bound",
    "estimated_ad_recall_rate_upper_bound",
    "estimated_ad_recallers_lower_bound",
    "estimated_ad_recallers_upper_bound"
  ),


  ## Auction and bidding
  auction = c(
    "ad_id",
    "buying_type",
    "auction_bid",
    "auction_competitiveness",
    "auction_max_competitor_bid",
    "wish_bid"
  ),

  ## Attribution
  attribution = c(
    "ad_id",
    "attribution_setting",
    "activity_recency"
  ),

  ## Audience
  audience = c(
    "ad_id",
    "age_targeting",
    "gender_targeting"
  ),
  dda = c(
    "ad_id",
    "dda_results",
    "dda_countby_convs",
    "cost_per_dda_countby_convs",
    "dma"
  ),
  location = c(
    "ad_id",
    "location",
    "country"
  ),

  ## Other
  others = c(
    "instagram_upcoming_event_reminders_set",
    "comparison_node",
    "publisher_platform",
    "device_platform",
    "platform_position",
    "impression_device",
    "redownload",
    "fidelity_type",
    "hsid",
    "postback_sequence_index",
    "impressions_dummy",
    "labels",
    "qualifying_question_qualify_answer_rate"
  )
)


usethis::use_data(cc_valid_fields_ad_insights, overwrite = TRUE)
