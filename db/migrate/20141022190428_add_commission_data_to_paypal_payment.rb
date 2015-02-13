class AddCommissionDataToPaypalPayment < ActiveRecord::Migration
  def change
    add_column :paypal_payments, :commission_payment_id, :string, limit: 64
    add_column :paypal_payments, :commission_payment_date, :datetime
    add_column :paypal_payments, :commission_status, :string, default: "not_charged", null: false, limit: 64
    add_column :paypal_payments, :commission_pending_reason, :string, limit: 64
    add_column :paypal_payments, :commission_total_cents, :integer
    add_column :paypal_payments, :commission_fee_total_cents, :integer
  end
end
