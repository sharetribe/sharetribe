module PlanService::API
  class Api
    Configuration = PlanService::DataTypes::Configuration

    def self.plans
      @plans ||= PlanService::API::Plans.new(build_configuration(environment))
    end

    def self.logger
      @logger ||= build_logger(log_target)
    end

    # private

    def self.log_target
      @log_target ||= build_log_target
    end

    def self.reset!
      @plans = nil
      @logger = nil
      @log_target = nil
    end

    def self.environment()
      @env || default_test_environment
    end

    def self.default_test_environment()
      {
        active: true,
        jwt_secret: "test_secret"
      }
    end

    def self.set_environment(env)
      @env = default_test_environment.merge(env)
    end

    def self.build_configuration(env)
      Configuration.call(env)
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
