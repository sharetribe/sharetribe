class AddOnboardingFieldsToOrderPermissions < ActiveRecord::Migration
  def up
    add_column :order_permissions, :onboarding_id, :string, limit: 36, null: true
    add_column :order_permissions, :permissions_granted, :boolean, null: true
    change_column :order_permissions, :request_token, :string, null: true
  end

  def down
    remove_column :order_permissions, :onboarding_id
    remove_column :order_permissions, :permissions_granted
    change_column :order_permissions, :request_token, :string, null: false
  end
end
