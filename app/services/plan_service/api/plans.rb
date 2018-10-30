module PlanService::API
  class Plans
    PlanStore = PlanService::Store::Plan

    Plan                     = PlanService::DataTypes::Plan
    ExternalPlan             = PlanService::DataTypes::ExternalPlan
    LoginLinkMarketplaceData = PlanService::DataTypes::LoginLinkMarketplaceData

    def initialize(configuration)
      @jwt_secret = configuration[:jwt_secret]
      @external_plan_service_login_url = configuration[:external_plan_service_login_url]
    end

    def active?
      true
    end

    def authorize_provisioning(token)
      JWTUtils.decode(token, @jwt_secret, sub: :provisioning)
    end

    def authorize_trial_sync(token)
      JWTUtils.decode(token, @jwt_secret, sub: :trial_sync)
    end

    def create(community_id:, plan:)
      Result::Success.new(
        with_statuses(
          PlanStore.create(community_id: community_id, plan: plan)))
    end

    # Create an initial trial plan
    #
    # deprecated
    #
    # All plans should come from the external plan service and that's
    # why this function is deprecated
    #
    def create_initial_trial(community_id:, plan: {})
      Result::Success.new(
        with_statuses(
          PlanStore.create_trial(community_id: community_id, plan: plan)))
    end

    def get_current(community_id:)
      Maybe(PlanStore.get_current(community_id: community_id)).map { |plan|
        Result::Success.new(with_statuses(plan))
      }.or_else {
        Result::Error.new("Cannot find plan for community id: #{community_id}")
      }
    end

    def get_trials(after:, limit:)
      # Fetch one extra, so that we can return the next_after
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
      Maybe(@external_plan_service_login_url).map { |external_plan_service_login_url|
        marketplace = LoginLinkMarketplaceData.call(marketplace_data)

        trial_hash = Maybe(PlanStore.get_initial_trial(community_id: marketplace[:id])).map { |trial_data|
          ExternalPlan.call(
            HashUtils.rename_keys(
            {
              id: :marketplace_plan_id,
              community_id: :marketplace_id
            }, trial_data))
        }.or_else(nil)

        payload = {
          marketplace: marketplace,
          initial_trial_plan: trial_hash
        }

        token = JWTUtils.encode(payload, @jwt_secret, sub: :login, exp: 5.minutes.from_now)
        Result::Success.new(URLUtils.append_query_param(external_plan_service_login_url, "token", token))
      }.or_else {
        Result::Error.new("external_plan_service_login_url is not defined")
      }
    end

    private

    def with_statuses(plan)
      plan.merge(
        expired: plan_expired?(plan),
        closed: plan_closed?(plan)
      )
    end

    # Return true, if plan is closed, i.e.
    # - Hold plan
    # - Expired non-trial plan
    def plan_closed?(plan)
      Maybe(plan).map { |p|
        if p[:status] == :hold
          true
        else
          plan_expired?(p) && p[:status] == :active
        end
      }.or_else(false)
    end

    def plan_expired?(plan)
      Maybe(plan)[:expires_at]
        .map { |expires_at| expires_at < Time.now }
        .or_else(false)
    end
  end
end
