module PlanService::ExternalPlanServiceInjector
  Configuration = DataTypes::Configuration

  @@active = true

  def external_plan_service
    Configuration.call(
      {
        active: @@active,
        jwt_secret: "test_secret"
      })
  end

  def logger
    @logger ||= SharetribeLogger.new(:external_plan_service,
                                     [:marketplace_id, :marketplace_ident, :user_id, :username, :request_uuid],
                                     log_target)
  end

  module_function

  # only for testing

  def log_target
    @@log_target ||= TestLogTarget.new
  end

  def set_active(bool)
    @@active = bool
  end
end
