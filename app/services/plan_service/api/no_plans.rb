module PlanService::API

  class NoPlans

    def active?
      false
    end

    def authorize(token)
      not_in_use
    end

    def create(community_id:, plan:)
      not_in_use
    end

    def create_initial_trial(community_id:, plan:)
      not_in_use
    end

    def get_current(community_id:)
      Result::Success.new(
        Plan.call(
        community_id: community_id,
        plan_level: PlanService::Levels::OS,
        expires_at: nil,
        created_at: Time.now,
        updated_at: Time.now)
      )
    end

    def expired?(community_id:)
      Result::Success.new(false)
    end

    def get_trials(after:)
      not_in_use
    end

    # private

    def not_in_use
      Result::Error.new("Plan service is not in use.")
    end
  end
end
