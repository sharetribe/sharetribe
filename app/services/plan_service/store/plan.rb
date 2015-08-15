module PlanService::Store::Plan

  Plan = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:plan_level, :fixnum, :mandatory],
    [:expires_at, :time, :optional] # Passing nil means that the plan never expires
  )

  module_function

  def create(community_id:, plan:)
    plan_entity = Plan.call(plan.merge(community_id: community_id))
    from_model(CommunityPlan.create!(plan_entity))
  end

  def get_current(community_id:)
    plan_model = CommunityPlan
                 .where(:community_id => community_id)
                 .order("created_at DESC")
                 .first

    from_model(plan_model)
  end

  def from_model(model)
    Maybe(model).map { |m|
      Plan.call(EntityUtils.model_to_hash(m))
    }.or_else(nil)
  end

end
