module PlanService::API
  class Api
    def self.plans
      @plans ||= PlanService::API::Plans.new
    end
  end
end
