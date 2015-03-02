class AddListingShapeIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :listing_shape_id, :int, after: :transaction_type_id
  end
end
