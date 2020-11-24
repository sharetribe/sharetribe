class AddUnitTypeToListing < ActiveRecord::Migration
  def change
    add_column :listings, :unit_type, :string, limit: 32, after: :quantity
  end
end
