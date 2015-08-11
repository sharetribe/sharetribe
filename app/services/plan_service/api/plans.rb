module PlanService::API
  PlanStore = PlanService::Store::Plan

  class Plans

    def create(community_id:, plan:)
      Result::Success.new(PlanStore.create(community_id: community_id, plan: plan))
    end

    def get_current(community_id:)
      Maybe(PlanStore.get_current(community_id: community_id)).map { |plan|
        Result::Success.new(plan)
      }.or_else {
        Result::Error.new("Can not find plan for community id: #{community_id}")
      }
    end
  end
end
