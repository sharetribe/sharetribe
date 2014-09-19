class RemodelBillingAgreement < ActiveRecord::Migration
  def up
    rename_column(:billing_agreements, :from_account_id, :paypal_account_id)
    remove_columns(:billing_agreements, :to_account_id, :status)
    add_column(:billing_agreements, :paypal_username_to, :string, null: false)
    add_column(:billing_agreements, :request_token, :string, null: false)
  end

  def down
    rename_column(:billing_agreements, :paypal_account_id, :from_account_id)
    add_column(:billing_agreements, :to_account_id, :integer, null: false)
    add_column(:billing_agreements, :status, :string, null: false, default: "pending")
    remove_column(:billing_agreements, :paypal_username_to)
    remove_column(:billing_agreements, :request_token)
  end
end
