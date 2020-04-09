class AllowNullListingShapeForListings < ActiveRecord::Migration[5.2]
  def up
    change_column :listings, :listing_shape_id, :int, :null => true
  end

  def down
    change_column :listings, :listing_shape_id, :int, :null => false
  end
end
