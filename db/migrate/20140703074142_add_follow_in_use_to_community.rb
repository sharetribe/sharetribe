class AddFollowInUseToCommunity < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :follow_in_use, :boolean, :default => true, :null => false
  end
end
