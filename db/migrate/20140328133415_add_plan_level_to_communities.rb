class AddPlanLevelToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :plan_level, :integer, :default => 0
  end
end
