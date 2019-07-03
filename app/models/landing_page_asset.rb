# == Schema Information
#
# Table name: landing_page_assets
#
#  id                 :bigint           not null, primary key
#  community_id       :integer
#  asset_id           :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class LandingPageAsset < ApplicationRecord
  belongs_to :community

  if (APP_CONFIG.clp_s3_bucket_name && APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key)
    has_attached_file :image, :path => ":site_name/:filename", s3_credentials: {
        bucket: APP_CONFIG.clp_s3_bucket_name,
        access_key_id: APP_CONFIG.aws_access_key_id,
        secret_access_key: APP_CONFIG.aws_secret_access_key
      }
  else
    has_attached_file :image,
      :path => ":rails_root/public/landing_page/:site_name/:filename",
      :url => ":filename"
  end

  Paperclip.interpolates :site_name do |attachment, style|
    attachment.instance.community.ident
  end

  validates_attachment_size :image, :less_than => APP_CONFIG.max_image_filesize.to_i, :unless => proc {|model| model.image.nil? }
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"], # the two last types are sent by IE.
                                    :unless => proc {|model| model.image.nil? }

end
