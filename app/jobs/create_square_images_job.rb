class CreateSquareImagesJob < Struct.new(:image_id)

  PAPERCLIP_OPTIONS =
    if (APP_CONFIG.s3_bucket_name && APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key)
      {
        :path => "images/listing_images/:attachment/:id/:style/:filename",
        :url => ":s3_domain_url"
      }
    else
      {
        :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
        :url => "/system/:attachment/:id/:style/:filename"
      }
    end

  class ListingImage < ApplicationRecord
    self.primary_key = "id"

    has_attached_file(:image, {
      styles: {
        :square => "408x408#",
        :square_2x => "816x816#"
    }}.merge(PAPERCLIP_OPTIONS))

    validates_attachment_size :image, :less_than => 9.megabytes
    validates_attachment_content_type :image,
                                      :content_type => ["image/jpeg", "image/png", "image/gif",
                                                        "image/pjpeg", "image/x-png"] #the two last types are sent by IE.
  end

  def perform
    ListingImage.find(image_id).image.reprocess_without_delay!(:square, :square_2x)
  end
end

