class AddEmailHashToListingImages < ActiveRecord::Migration[5.2]
  def change
    add_column :listing_images, :email_hash, :string
  end
end
