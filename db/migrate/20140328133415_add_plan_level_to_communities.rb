class AddPlanLevelToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :plan_level, :integer, :default => 0
  end
end
