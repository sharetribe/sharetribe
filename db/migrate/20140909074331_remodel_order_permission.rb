class RemodelOrderPermission < ActiveRecord::Migration
  def up
    rename_column(:order_permissions, :from_account_id, :paypal_account_id)
    remove_columns(:order_permissions, :to_account_id, :status)
    add_column(:order_permissions, :request_token, :string, null: false)
    add_column(:order_permissions, :paypal_username_to, :string, null: false)
    add_column(:order_permissions, :scope, :string, null: false)
    add_column(:order_permissions, :verification_code, :string, null: true)
  end

  def down
    rename_column(:order_permissions, :paypal_account_id, :from_account_id)
    add_column(:order_permissions, :to_account_id, :integer, null: false)
    add_column(:order_permissions, :status, :string, null: false, default: "pending")
    remove_columns(:order_permissions, :request_token, :paypal_username_to, :scope, :verification_code)
  end
end
