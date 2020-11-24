class AddQuantityToListings < ActiveRecord::Migration
  def change
    add_column :listings, :quantity, :string
  end
end
