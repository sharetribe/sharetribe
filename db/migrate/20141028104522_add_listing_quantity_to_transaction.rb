class AddListingQuantityToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :listing_quantity, :int, default: 1
  end
end
