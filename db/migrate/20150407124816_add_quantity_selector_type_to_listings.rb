class AddQuantitySelectorTypeToListings < ActiveRecord::Migration
  def change
    add_column :listings, :quantity_selector_type, :string, limit: 32, after: :unit_type
  end
end
