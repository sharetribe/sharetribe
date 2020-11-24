class AddImageDownloadedToListingImages < ActiveRecord::Migration
  def change
    add_column :listing_images, :image_downloaded, :boolean, :after => :image_processing, :default => false
  end
end
