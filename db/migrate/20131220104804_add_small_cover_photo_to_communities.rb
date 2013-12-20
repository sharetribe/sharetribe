class AddSmallCoverPhotoToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :small_cover_photo_file_name, :string
    add_column :communities, :small_cover_photo_content_type, :string
    add_column :communities, :small_cover_photo_file_size, :integer
    add_column :communities, :small_cover_photo_updated_at, :datetime
  end
end
