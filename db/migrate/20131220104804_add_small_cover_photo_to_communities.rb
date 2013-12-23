class AddSmallCoverPhotoToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :small_cover_photo_file_name, :string, :after => :cover_photo_updated_at
    add_column :communities, :small_cover_photo_content_type, :string, :after => :small_cover_photo_file_name
    add_column :communities, :small_cover_photo_file_size, :integer, :after => :small_cover_photo_content_type
    add_column :communities, :small_cover_photo_updated_at, :datetime, :after => :small_cover_photo_file_size
  end
end
