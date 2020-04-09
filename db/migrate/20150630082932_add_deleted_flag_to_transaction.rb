class AddDeletedFlagToTransaction < ActiveRecord::Migration[5.2]
def change
    add_column :transactions, :deleted, :boolean, default: false, after: :shipping_price_cents
  end
end
