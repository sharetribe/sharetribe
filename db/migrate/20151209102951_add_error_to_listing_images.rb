class AddErrorToListingImages < ActiveRecord::Migration
  def up
    add_column :listing_images, :error, :string, null: true, after: :image_downloaded
  end

  def down
    drop_column :listing_images, :error
  end
end
