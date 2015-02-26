class AddShippingFieldsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :require_shipping_address, :boolean, default: false
    add_column :transactions, :pickup_enabled, :boolean, default: false
    add_column :transactions, :shipping_price_cents, :integer
  end
end
