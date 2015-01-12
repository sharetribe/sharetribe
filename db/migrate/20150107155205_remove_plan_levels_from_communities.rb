class RemovePlanLevelsFromCommunities < ActiveRecord::Migration
  def up
    remove_column :communities, :plan_level
  end

  def down
    add_column :communities, :plan_level, :integer
  end
end
