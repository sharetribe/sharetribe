class AddErrorStatusToListingImage < ActiveRecord::Migration
  def change
    add_column :listing_images, :errored, :boolean, after: :image_downloaded, default: false, null: false
  end
end
