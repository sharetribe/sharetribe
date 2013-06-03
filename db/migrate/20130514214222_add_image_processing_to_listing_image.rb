class AddImageProcessingToListingImage < ActiveRecord::Migration
  def change
    add_column :listing_images, :image_processing, :boolean
  end
end
