module PlanService::API
  class Api
    Configuration = PlanService::DataTypes::Configuration

    def self.plans
      @plans ||= build_plans_api
    end

    def self.logger
      @logger ||= build_logger
    end

    # private

    def self.build_plans_api
      configuration = build_configuration()

      if configuration[:active]
        PlanService::API::Plans.new(configuration)
      else
        PlanService::API::NoPlans.new()
      end
    end

    def self.build_configuration()
      Configuration.call(
        active: APP_CONFIG.external_plan_service_in_use,
        external_plan_service_login_url: APP_CONFIG.external_plan_service_login_url,
        jwt_secret: APP_CONFIG.external_plan_service_secret
      )
    end

    def self.build_logger()
      SharetribeLogger.new(:external_plan_service,
                           [:marketplace_id, :marketplace_ident, :user_id, :username, :request_uuid])
    end
  end
end
