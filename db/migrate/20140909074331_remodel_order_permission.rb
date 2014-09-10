class RemodelOrderPermission < ActiveRecord::Migration
  def change
    rename_column(:order_permissions, :from_account_id, :paypal_account_id)
    remove_columns(:order_permissions, :to_account_id, :status)
    add_column(:order_permissions, :request_token, :string, null: false)
    add_column(:order_permissions, :paypal_username_to, :string, null: false)
    add_column(:order_permissions, :scope, :string, null: false)
    add_column(:order_permissions, :verification_code, :string, null: true)
  end
end
