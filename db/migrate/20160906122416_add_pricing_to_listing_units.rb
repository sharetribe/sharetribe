class AddPricingToListingUnits < ActiveRecord::Migration
  def change
    add_column :listing_units, :pricing, :string, limit: 32, after: :label
  end
end
