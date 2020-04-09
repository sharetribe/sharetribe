class AddSelectorToListingUnits < ActiveRecord::Migration[5.2]
def change
    add_column :listing_units, :quantity_selector, :string, limit: 32, after: :unit_type, null: false
  end
end
