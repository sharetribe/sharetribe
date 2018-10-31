class AddBuyerCommissionToStripePayments < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_payments, :buyer_commission_cents, :integer
  end
end
