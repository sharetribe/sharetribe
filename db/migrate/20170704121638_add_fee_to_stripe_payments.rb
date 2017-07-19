class AddFeeToStripePayments < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_payments, :fee_cents, :integer
  end
end
