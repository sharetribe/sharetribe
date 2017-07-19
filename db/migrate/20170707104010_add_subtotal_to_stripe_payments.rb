class AddSubtotalToStripePayments < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_payments, :subtotal_cents, :integer
  end
end
