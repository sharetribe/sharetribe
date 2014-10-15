class RemoveUnnecessaryCommunityDefaults < ActiveRecord::Migration
  def up
    remove_column :communities, :category_change_allowed
    remove_column :communities, :custom_fields_allowed
    remove_column :communities, :privacy_policy_change_allowed
    remove_column :communities, :terms_change_allowed
    change_column :communities, :feedback_to_admin, :boolean, :default => true
  end

  def down
    add_column :communities, :category_change_allowed, :boolean, :default => false
    add_column :communities, :custom_fields_allowed, :boolean, :default => false
    add_column :communities, :privacy_policy_change_allowed, :boolean, :default => false
    add_column :communities, :privacy_policy_change_allowed, :boolean, :default => false
    change_column :communities, :feedback_to_admin, :boolean, :default => false
  end
end
