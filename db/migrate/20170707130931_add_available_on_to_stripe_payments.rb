class AddAvailableOnToStripePayments < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_payments, :available_on, :datetime
  end
end
