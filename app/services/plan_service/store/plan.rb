module PlanService::Store::Plan

  class TrialModel < ActiveRecord::Base
    self.table_name = :marketplace_trials
  end

  class PlanModel < ActiveRecord::Base
    self.table_name = :marketplace_plans
  end

  NewPlan = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:plan_level, :fixnum, :mandatory],
    [:expires_at, :time, :optional], # Passing nil means that the plan never expires
  )

  NewTrialPlan = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:expires_at, :time],
  )

  Plan = PlanService::DataTypes::Plan

  module_function

  # deprecated
  # use create_trial or create_plan
  def create(community_id:, plan:)
    plan_entity = NewPlan.call(plan.merge(community_id: community_id))
    from_model(CommunityPlan.create!(plan_entity))
  end

  def create_trial(community_id:, plan:)
    plan_entity = NewTrialPlan.call(plan.merge(community_id: community_id, plan_level: PlanService::Levels::FREE))
    from_trial_model(TrialModel.create!(plan_entity))
  end

  def create_plan(community_id:, plan:)
    plan_entity = NewPlan.call(plan.merge(community_id: community_id))
    from_model(PlanModel.create!(plan_entity))
  end

  def get_current(community_id:)
    plan_model = CommunityPlan
                 .where(:community_id => community_id)
                 .order("created_at DESC")
                 .first

    from_model(plan_model)
  end

  def get_trials(after:)
    CommunityPlan.where("created_at >= ?", after).map { |plan_model|
      from_model(plan_model)
    }
  end

  def from_model(model)
    Maybe(model).map { |m|
      Plan.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end

  def from_trial_model(model)
    Maybe(model).map { |m|
      Plan.call(EntityUtils.model_to_hash(m).merge(plan_level: 0))
    }.or_else(nil)
  end

end
