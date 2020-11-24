class RemovePlanLevelFromPlans < ActiveRecord::Migration
  def up
    remove_column :marketplace_plans, :plan_level
  end

  def down
    add_column :marketplace_plans, :plan_level, :integer, after: :community_id
  end
end
