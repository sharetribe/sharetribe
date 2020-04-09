class RemovePlanFromCommunity < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :plan
  end

  def down
    add_column :communities, :plan, :string
  end
end
