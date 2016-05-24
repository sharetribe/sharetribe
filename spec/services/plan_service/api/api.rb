module PlanService::API
  class Api
    Configuration = PlanService::DataTypes::Configuration

    def self.plans
      configuration = build_configuration()

      @plans ||=
        if configuration[:active]
          PlanService::API::Plans.new(configuration)
        else
          PlanService::API::NoPlans.new()
        end
    end

    def self.logger
      @logger ||= build_logger(log_target)
    end

    def self.reset!
      @plans = nil
    end

    # private

    def self.log_target
      @log_target ||= build_log_target
    end

    def self.environment()
      @env || default_test_environment
    end

    def self.default_test_environment()
      {
        active: false,
        jwt_secret: "test_secret",
        external_plan_service_login_url: "http://external.plan.service.com",
      }
    end

    def self.set_environment(env)
      @env = default_test_environment.merge(env)
    end

    def self.build_configuration()
      Configuration.call(environment())
    end

    def self.build_logger(log_target)
      SharetribeLogger.new(:external_plan_service,
                           [:marketplace_id, :marketplace_ident, :user_id, :username, :request_uuid],
                           log_target)
    end

    def self.build_log_target
      TestLogTarget.new
    end
  end
end
