class AddAuthorIdToListingImage < ActiveRecord::Migration
  def change
    add_column :listing_images, :author_id, :string
  end
end
