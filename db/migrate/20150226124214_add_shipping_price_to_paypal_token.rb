class AddShippingPriceToPaypalToken < ActiveRecord::Migration
  def change
    add_column :paypal_tokens, :shipping_total_cents, :integer
  end
end
