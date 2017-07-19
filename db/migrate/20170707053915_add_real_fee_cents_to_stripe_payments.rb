class AddRealFeeCentsToStripePayments < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_payments, :real_fee_cents, :integer
  end
end
