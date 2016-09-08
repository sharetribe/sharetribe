class CreateSquareImagesJob < Struct.new(:image_id)

  class ListingImage < ActiveRecord::Base
    self.primary_key = "id"

    has_attached_file(:image, styles: {
      :square => "408x408#",
      :square_2x => "816x816#"
    })

    validates_attachment_size :image, :less_than => 9.megabytes
    validates_attachment_content_type :image,
                                      :content_type => ["image/jpeg", "image/png", "image/gif",
                                        "image/pjpeg", "image/x-png"] #the two last types are sent by IE.
  end

  def perform
    ListingImage.find(image_id).image.reprocess_without_delay!(:square, :square_2x)
  end
end
