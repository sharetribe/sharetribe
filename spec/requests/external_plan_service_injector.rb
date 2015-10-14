module PlanService::ExternalPlanServiceInjector
  def external_plan_service
    {
      jwt_secret: "test_secret"
    }
  end

  def logger
    @logger ||= SharetribeLogger.new(:external_plan_service,
                                     [:marketplace_id, :marketplace_ident, :user_id, :username, :request_uuid],
                                     log_target)
  end

  module_function

  def log_target
    @@log_target ||= TestLogTarget.new
  end
end
