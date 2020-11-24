class AddShippingEnabledToTransactionType < ActiveRecord::Migration
  def change
    add_column :transaction_types, :shipping_enabled, :boolean, default: false, allow_nil: false
  end
end
