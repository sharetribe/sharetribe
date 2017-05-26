class AddPositionToListingImages < ActiveRecord::Migration
  def change
    add_column :listing_images, :position, :integer, default: 0
  end
end
