class AddQuantitySelectorTypeToListings < ActiveRecord::Migration[5.2]
def change
    add_column :listings, :quantity_selector, :string, limit: 32, after: :unit_type
  end
end
