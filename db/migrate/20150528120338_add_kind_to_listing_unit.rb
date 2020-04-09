class AddKindToListingUnit < ActiveRecord::Migration[5.2]
def change
    add_column :listing_units, :kind, :string, limit: 32, after: :quantity_selector, null: false
  end
end
