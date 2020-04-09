class AddPaymentActionToPaypalToken < ActiveRecord::Migration[5.2]
  def change
    add_column :paypal_tokens, :payment_action, :string, limit: 32, after: :transaction_id, null: true
  end
end
