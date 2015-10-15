module PlanService::DataTypes
  Configuration = EntityUtils.define_builder(
    [:active, :str_to_bool, :to_bool, :mandatory],
    [:jwt_secret, :string, :optional] # Not needed if not in use
  )
end
