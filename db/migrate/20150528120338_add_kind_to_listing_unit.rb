class AddKindToListingUnit < ActiveRecord::Migration
  def change
    add_column :listing_units, :kind, :string, limit: 32, after: :quantity_selector, null: false
  end
end
