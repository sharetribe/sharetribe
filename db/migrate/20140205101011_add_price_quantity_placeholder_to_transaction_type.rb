class AddPriceQuantityPlaceholderToTransactionType < ActiveRecord::Migration
  def change
    add_column :transaction_types, :price_quantity_placeholder, :string, :after => :price_field
  end
end
