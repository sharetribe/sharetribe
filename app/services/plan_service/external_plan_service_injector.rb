module PlanService::ExternalPlanServiceInjector
  def external_plan_service
    @external_plan_service ||= build_external_plan_service
  end

  module_function

  def build_external_plan_service
    {
      jwt_secret: APP_CONFIG.external_plan_service_jwt_secret
    }
  end
end
