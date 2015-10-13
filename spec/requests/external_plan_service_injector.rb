module PlanService::ExternalPlanServiceInjector
  def external_plan_service
    {
      jwt_secret: "test_secret"
    }
  end
end
