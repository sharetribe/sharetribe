class AddLabelToListingUnits < ActiveRecord::Migration
  def change
    add_column :listing_units, :label, :string, limit: 32, after: :id
  end
end
