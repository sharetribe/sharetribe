class AddCommisionRetryCountToPaypalPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :paypal_payments, :commission_retry_count, :integer, default: 0
  end
end
