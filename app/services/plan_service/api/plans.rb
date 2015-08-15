module PlanService::API
  PlanStore = PlanService::Store::Plan

  class Plans

    def create(community_id:, plan:)
      Result::Success.new(
        with_expiration_status(
          PlanStore.create(community_id: community_id, plan: plan)))
    end

    def get_current(community_id:)
      Maybe(PlanStore.get_current(community_id: community_id)).map { |plan|
        Result::Success.new(with_expiration_status(plan))
      }.or_else {
        Result::Error.new("Can not find plan for community id: #{community_id}")
      }
    end

    def expired?(community_id:)
      Maybe(PlanStore.get_current(community_id: community_id)).map { |plan|
        Result::Success.new(
          Maybe(plan[:expires_at]).map { |expires_at|
            expires_at < Time.now }
          .or_else(false))
      }.or_else {
        Result::Error.new("Can not find plan for community id: #{community_id}")
      }
    end

    private

    def with_expiration_status(plan)
      plan.merge(
        expired: plan_expired?(plan)
      )
    end

    def plan_expired?(plan)
      Maybe(plan)[:expires_at]
        .map { |expires_at| expires_at < Time.now }
        .or_else(false)
    end
  end
end
