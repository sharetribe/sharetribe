module PlanService::DataTypes
  Configuration = EntityUtils.define_builder(
    [:active, :str_to_bool, :to_bool, :mandatory],
    [:jwt_secret, :string, :optional], # Not needed if not in use
    [:external_plan_service_login_url, :string, :optional] # Not needed if not in use
  )

  Plan = EntityUtils.define_builder(
    [:id, :fixnum, :optional], # For OS, the plan is not actually in DB. Thus, optional.
    [:community_id, :fixnum, :mandatory],
    [:plan_level, :fixnum, :mandatory],
    [:expires_at, :time, :optional],
    [:created_at, :time, :mandatory],
    [:updated_at, :time, :mandatory],
  )

  ExternalPlan = EntityUtils.define_builder(
    [:marketplace_plan_id, :fixnum, :mandatory],
    [:marketplace_id, :fixnum, :mandatory],
    [:plan_level, :fixnum, :mandatory],
    [:expires_at, :time, :optional],
    [:created_at, :time, :mandatory],
    [:updated_at, :time, :mandatory],
  )

  LoginLinkMarketplaceData = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:ident, :string, :mandatory],
    [:domain, :string],
    [:marketplace_default_name, :string]
  )

end
