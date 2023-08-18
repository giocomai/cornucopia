## code to prepare `cc_valid_fields_ad_insights_v` dataset goes here
# https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/

## cannot ask all together, hence need to be separated

cc_valid_fields_ad_insights_v <- c(
  # about the account
  "account_id",
  "account_name",
  
  # about the ad
  "campaign_name",
  "campaign_id",
  "adset_name",
  "adset_id",
  "ad_name",
  "ad_id",
  "created_time",
  "updated_time",
  "date_start",
  "date_stop",
  
  "objective",
  "optimization_goal",
  

  
  # money
  "account_currency",
  "spend",
  "social_spend",
  
  # actions and conversions
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

  "video_30_sec_watched_actions",
  
  
  "conversions",
  "cost_per_conversion",
  "cost_per_unique_conversion",
  "conversion_values",
  "coarse_conversion_value",
  
  "conversion_rate_ranking",
  
  "dda_results",
  "dda_countby_convs",
  "cost_per_dda_countby_convs",
  "dma",
  
  "cpc",
  "cpm",
  "cpp",
  "ctr",
  "website_ctr",
  "frequency",
  "frequency_value",
  "reach",
  
  ## Viewing
  "canvas_avg_view_percent",
  "canvas_avg_view_time",
  
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
  "full_view_reach",
  
  ## Time
  
  "hourly_stats_aggregated_by_advertiser_time_zone",
  "hourly_stats_aggregated_by_audience_time_zone",
  
  ## Instant experience
  "instant_experience_clicks_to_open",
  "instant_experience_clicks_to_start",
  "instant_experience_outbound_clicks",
  "interactive_component_tap",
  
  ## Catalog
  
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
  "qualifying_question_qualify_answer_rate",
  
  "converted_product_quantity",
  "converted_product_value",
  
  # Ad recall
  
  "estimated_ad_recall_rate_lower_bound",
  "estimated_ad_recall_rate_upper_bound",
  "estimated_ad_recallers_lower_bound",
  "estimated_ad_recallers_upper_bound",
  
  
  ## Auction and bidding
  "buying_type",
  "auction_bid",
  "auction_competitiveness",
  "auction_max_competitor_bid",
  "wish_bid",
  
  ## Attribution
  "attribution_setting",
  "activity_recency",
  
  ## Audience
  "age_targeting",
  "gender_targeting",
  
  ## Other
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
  
  "labels",
  "location",
  "country"
)

# excluded for incompatibility

asset_related <- c(
  "title_asset",
  "ad_format_asset",
  "image_asset",
  "media_asset",
  "video_asset",
  "body_asset",
  "description_asset",
  "rule_asset"
)

others <- c("impressions_dummy")


usethis::use_data(cc_valid_fields_ad_insights_v, overwrite = TRUE)
