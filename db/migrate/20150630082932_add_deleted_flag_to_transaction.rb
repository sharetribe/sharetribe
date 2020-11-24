class AddDeletedFlagToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :deleted, :boolean, default: false, after: :shipping_price_cents
  end
end
