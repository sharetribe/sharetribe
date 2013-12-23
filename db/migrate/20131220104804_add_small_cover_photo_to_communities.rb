require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class AddSmallCoverPhotoToCommunities < ActiveRecord::Migration
  include LoggingHelper

  class Community < ActiveRecord::Base
    has_attached_file :cover_photo
    has_attached_file :small_cover_photo, :styles => { 
        :header => "1600x195#",
        :hd_header => "1920x96#",
        :original => "3840x3840>"
      },
      :path => "images/communities/:attachment/:id/:style/:filename",
  end
  
  def up
    add_column :communities, :small_cover_photo_file_name, :string, :after => :cover_photo_updated_at
    add_column :communities, :small_cover_photo_content_type, :string, :after => :small_cover_photo_file_name
    add_column :communities, :small_cover_photo_file_size, :integer, :after => :small_cover_photo_content_type
    add_column :communities, :small_cover_photo_updated_at, :datetime, :after => :small_cover_photo_file_size

    Community.reset_column_information

    Community.where("cover_photo_file_name IS NOT NULL").find_each do |community|
      community.small_cover_photo = community.cover_photo
      community.save!
      print_dot
    end
  end

  def down
    remove_attachment :communities, :small_cover_photo
  end
end
