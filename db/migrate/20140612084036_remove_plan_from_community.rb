class RemovePlanFromCommunity < ActiveRecord::Migration
  def up
    remove_column :communities, :plan
  end

  def down
    add_column :communities, :plan, :string
  end
end
