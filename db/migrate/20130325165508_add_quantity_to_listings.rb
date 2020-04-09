class AddQuantityToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :quantity, :string
  end
end
