class RemoveHideRealNameFunctionality < ActiveRecord::Migration
  def up
    remove_column :communities, :select_whether_name_is_shown_to_everybody
    remove_column :people, :show_real_name_to_other_users
  end

  def down
    add_column :communities, :select_whether_name_is_shown_to_everybody, :boolean, :default => 0
    add_column :people, :show_real_name_to_other_users, :boolean, :default => 1
  end
end
