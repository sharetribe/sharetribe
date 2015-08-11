module PlanService::API
  PlanStore = PlanService::Store::Plan

  class Plans

    PLANS = {
      0 => :free,
      1 => :starter,
      2 => :basic,
      3 => :growth,
      4 => :scale
    }

    def create(community_id:, plan:)
      plan_w_level = plan.merge(plan_level: take_plan_level(plan))

      Result::Success.new(
        with_name_and_expired(
          PlanStore.create(community_id: community_id, plan: plan_w_level)))
    end

    def get_current(community_id:)
      Maybe(PlanStore.get_current(community_id: community_id)).map { |plan|
        Result::Success.new(with_name_and_expired(plan))
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

    def take_plan_level(plan)
      plan[:plan_level] || name_to_level(plan)
    end

    def name_to_level(plan)
      Maybe(PLANS.find { |(k, v)| v == plan[:plan_name] })
        .map { |(level, name)| level }
        .or_else(nil)
    end

    def with_name_and_expired(plan)
      plan.merge(
        plan_name: PLANS[plan[:plan_level]],
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
