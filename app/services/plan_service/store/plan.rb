module PlanService::Store::Plan

  class TrialModel < ApplicationRecord
    self.table_name = :marketplace_trials
  end

  class PlanModel < ApplicationRecord
    self.table_name = :marketplace_plans
    store :features, coder: JSON
  end

  NewPlan = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:status, :to_symbol, one_of: [:trial, :hold, :active]],
    [:features, :hash, :mandatory],
    [:member_limit, :fixnum, :optional],
    [:expires_at, :time, :optional] # Passing nil means that the plan never expires
  )

  NewTrialPlan = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:expires_at, :time]
  )

  Plan = PlanService::DataTypes::Plan

  module_function

  def create(community_id:, plan:)
    plan_entity = NewPlan.call(plan.merge(community_id: community_id))
    from_model(PlanModel.create!(plan_entity))
  end

  def create_trial(community_id:, plan:)
    plan_entity = NewTrialPlan.call(plan.merge(community_id: community_id))
    from_trial_model(TrialModel.create!(plan_entity))
  end

  def get_current(community_id:)
    Maybe(get_current_plan(community_id: community_id)).or_else {
      get_initial_trial(community_id: community_id)
    }
  end

  def get_trials(after:, limit:)
    sorted_trials = TrialModel.order(:created_at)

    trials_after =
      if after
        sorted_trials.where("created_at >= ?", after)
      else
        sorted_trials
      end

    trials_after.limit(limit).map { |plan_model|
      from_trial_model(plan_model)
    }
  end

  # private

  def get_current_plan(community_id:)
    plan_model = PlanModel.where(community_id: community_id)
                 .order("created_at DESC")
                 .first

    from_model(plan_model)
  end

  def get_initial_trial(community_id:)
    plan_model = TrialModel.where(community_id: community_id)
                 .order("created_at DESC")
                 .first

    from_trial_model(plan_model)
  end

  def from_model(model)
    Maybe(model).map { |m|
      Plan.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end

  def from_trial_model(model)
    Maybe(model).map { |m|
      Plan.call(EntityUtils.model_to_hash(m).merge(
        member_limit: 300,
        status: :trial,
        features: { deletable: true }))
    }.or_else(nil)
  end

end
