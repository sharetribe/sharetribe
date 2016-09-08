class AddAvailabilityToListingShape < ActiveRecord::Migration
  def change
    add_column :listing_shapes, :availability, :string, limit: 32, default: "none", after: :shipping_enabled
  end
end
