require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

module PathHelper
  def self.s3?
    (APP_CONFIG.s3_bucket_name && APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key)
  end
    
  def self.path
    p = PathHelper.s3? ? "images/communities/:attachment/:id/:style/:filename" : ":rails_root/public/system/:attachment/:id/:style/:filename"
  end
end

class CopySmallCoverPhotoFromCoverPhoto < ActiveRecord::Migration
  include LoggingHelper

  class Community < ActiveRecord::Base

    has_attached_file :cover_photo, :path => PathHelper.path
    has_attached_file :small_cover_photo, :styles => { 
        :header => "1600x195#",
        :hd_header => "1920x96#",
        :original => "3840x3840>"
      }, :path => PathHelper.path
  end
  
  def up
    Community.reset_column_information

    Community.where("cover_photo_file_name IS NOT NULL").find_each do |community|
      community.small_cover_photo = community.cover_photo
      community.save!
      print_dot
    end
  end

  def down

  end
end
