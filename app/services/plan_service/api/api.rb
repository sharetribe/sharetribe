module PlanService::API
  class Api
    extend PlanService::ExternalPlanServiceInjector

    def self.plans
      @plans ||= PlanService::API::Plans.new(external_plan_service) # Provided by the injector
    end
  end
end
