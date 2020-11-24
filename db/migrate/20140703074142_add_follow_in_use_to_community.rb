class AddFollowInUseToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :follow_in_use, :boolean, :default => true, :null => false
  end
end
