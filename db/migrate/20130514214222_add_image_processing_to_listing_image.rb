class AddImageProcessingToListingImage < ActiveRecord::Migration[5.2]
def change
    add_column :listing_images, :image_processing, :boolean
  end
end
