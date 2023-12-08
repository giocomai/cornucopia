## code to prepare `cc_valid_fields_ad_campaign_group_v` dataset goes here

cc_valid_fields_ad_campaign_group_v <- c(
  "id",
  "name",
  "created_time",
  "updated_time",
  "start_time",
  "stop_time",
  "objective",
  "status",
  "configured_status",
  "effective_status",
  "daily_budget",
  "lifetime_budget",
  "spend_cap",
  "budget_remaining",
  "budget_rebalance_flag",
  "primary_attribution",
  "bid_strategy",
  "can_use_spend_cap",
  "is_budget_schedule_enabled",
  "boosted_object_id",
  "buying_type",
  "campaign_group_active_time",
  "can_create_brand_lift_study",
  "last_budget_toggling_time",
  "smart_promotion_type",
  "source_campaign_id",
  "special_ad_category",
  "has_secondary_skadnetwork_reporting",
  "is_skadnetwork_attribution",
  "topline_id"
)

usethis::use_data(cc_valid_fields_ad_campaign_group_v, overwrite = TRUE)
