class EnableCustomizableFooter < ActiveRecord::Migration[5.2]
  # Note this assumes the external_plan_service_in_use setting is set to true.
  # This migration alone won't enable it.
  COMMUNITY_ID = Community.first.id

  def up
    PlanService::Store::Plan::PlanModel.create(
      community_id: COMMUNITY_ID,
      status: "active",
      features: {"whitelabel"=>true, "admin_email"=>true, "footer"=>true},
      expires_at: Time.current + 20.years
    )
  end

  def down
    current_plan = PlanService::Store::Plan::PlanModel.where(
      community_id: COMMUNITY_ID,
      status: 'active'
    ).first
    current_plan.destroy
  end
end
