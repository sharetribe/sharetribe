class DeleteProfilePictureJob < Struct.new(:person_id, :image_file_name)

  PAPERCLIP_OPTIONS =
    if (APP_CONFIG.s3_bucket_name && APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key)
      {
        :path => "images/people/:attachment/:id/:style/:filename",
        :url => ":s3_domain_url"
      }
    else
      {
        :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
        :url => "/system/:attachment/:id/:style/:filename"
      }
    end

  class Person < ApplicationRecord
    self.primary_key = "id"

    has_attached_file(:image,
                      {
                        :styles => {
                          :medium => "288x288#",
                          :small => "108x108#",
                          :thumb => "48x48#",
                          :original => "600x800>"
                        }
                      }.merge(PAPERCLIP_OPTIONS))

    validates_attachment_size :image, :less_than => 9.megabytes
    validates_attachment_content_type :image,
                                      :content_type => ["image/jpeg", "image/png", "image/gif",
                                        "image/pjpeg", "image/x-png"] #the two last types are sent by IE.
  end

  def perform
    Person.new(id: person_id, image_file_name: image_file_name).image.destroy
  end
end
