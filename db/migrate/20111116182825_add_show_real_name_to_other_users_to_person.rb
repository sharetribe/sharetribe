class AddShowRealNameToOtherUsersToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :show_real_name_to_other_users, :boolean, :default => true
  end

  def self.down
    remove_column :people, :show_real_name_to_other_users
  end
end
