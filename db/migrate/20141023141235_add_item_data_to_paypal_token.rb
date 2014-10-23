class AddItemDataToPaypalToken < ActiveRecord::Migration
  def change
    add_column :paypal_tokens, :item_name, :string
    add_column :paypal_tokens, :item_quantity, :integer
    add_column :paypal_tokens, :item_price_cents, :integer
    add_column :paypal_tokens, :currency, :string, limit: 8
  end
end
