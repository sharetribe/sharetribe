class DeleteProfilePictureJob < Struct.new(:person_id, :image_file_name)

  class Person < ActiveRecord::Base
    self.primary_key = "id"

    has_attached_file(:image,
                      :styles => {
                        :medium => "288x288#",
                        :small => "108x108#",
                        :thumb => "48x48#",
                        :original => "600x800>"
                      },
                      path: "images/people/:attachment/:id/:style/:filename")

    validates_attachment_size :image, :less_than => 9.megabytes
    validates_attachment_content_type :image,
                                      :content_type => ["image/jpeg", "image/png", "image/gif",
                                        "image/pjpeg", "image/x-png"] #the two last types are sent by IE.
  end

  def perform
    Person.new(id: person_id, image_file_name: image_file_name).image.destroy
  end
end
