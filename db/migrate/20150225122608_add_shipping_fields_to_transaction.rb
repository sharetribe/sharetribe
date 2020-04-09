class AddShippingFieldsToTransaction < ActiveRecord::Migration[5.2]
def change
    add_column :transactions, :delivery_method, :string, limit: 31, default: "none"
    add_column :transactions, :shipping_price_cents, :integer
  end
end
