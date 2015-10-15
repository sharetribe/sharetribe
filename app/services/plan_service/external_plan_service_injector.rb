module PlanService::ExternalPlanServiceInjector
  Configuration = PlanService::DataTypes::Configuration

  def external_plan_service
    @external_plan_service ||= build_external_plan_service
  end

  def logger
    @logger ||= SharetribeLogger.new(:external_plan_service,
                                     [:marketplace_id, :marketplace_ident, :user_id, :username, :request_uuid])
  end

  module_function

  def build_external_plan_service
    Configuration.call({
                         active: APP_CONFIG.external_plan_service_in_use,
                         jwt_secret: APP_CONFIG.external_plan_service_secret
                       })
  end
end
