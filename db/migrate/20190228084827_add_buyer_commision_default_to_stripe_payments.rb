class AddBuyerCommisionDefaultToStripePayments < ActiveRecord::Migration[5.1]
  def change
    change_column :stripe_payments, :buyer_commission_cents, :integer, default: 0
  end
end
