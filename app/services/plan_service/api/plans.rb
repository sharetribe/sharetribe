module PlanService::API
  PlanStore = PlanService::Store::Plan

  Plan = PlanService::DataTypes::Plan

  class Plans

    def initialize(configuration)
      @jwt_secret = configuration[:jwt_secret]
    end

    def active?
      true
    end

    def authorize(token)
      JWTUtils.decode(token, @jwt_secret)
    end

    def create(community_id:, plan:)
      Result::Success.new(
        with_expiration_status(
          PlanStore.create(community_id: community_id, plan: plan)))
    end

    # Create an initial trial plan
    #
    # deprecated
    #
    # All plans should come from the external plan service and that's
    # why this function is deprecated
    #
    def create_initial_trial(community_id:, plan:)
      Result::Success.new(
        with_expiration_status(
          PlanStore.create_trial(community_id: community_id, plan: plan)))

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

    def get_trials(after:, limit:)
      # Fetch one extra, so that we can return the next_offset
      plus_one = limit + 1

      trials = PlanStore.get_trials(after: after, limit: plus_one)

      if trials.count > limit
        Result::Success.new(
          plans: trials.take(limit),
          next_after: trials.last[:created_at].to_i
        )
      else
        Result::Success.new(
          plans: trials
        )
      end
    end

    def get_external_service_link(marketplace_data)
      Maybe(APP_CONFIG.external_plan_service_url).map { |external_plan_service_url|
        marketplace_id = marketplace_data[:id]
        current_plan = get_current(community_id: marketplace_id).data

        payload = {
          marketplace: marketplace_data,
          current_plan: HashUtils.rename_keys({
              id: :marketplace_plan_id,
              community_id: :marketplace_id
            }, current_plan.slice(:id, :community_id, :plan_level, :expires_at, :created_at, :updated_at))
        }

        secret = APP_CONFIG.external_plan_service_secret
        external_plan_service_url = external_plan_service_url + "/login"
        token = JWTUtils.encode(payload, secret)
        URLUtils.append_query_param(external_plan_service_url, "token", token)
        }.or_else(Result::Error.new("external_plan_service_url is not defined"))
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
