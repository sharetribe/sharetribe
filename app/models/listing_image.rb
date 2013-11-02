class ListingImage < ActiveRecord::Base

  belongs_to :listing

  has_attached_file :image, :styles => {
        :small_3x2 => "240x160#",
        :medium => "360x270#",
        :thumb => "120x120#",
        :original => "1600x1600>",
        :big => "800x800>",
        :email => "150x100#"}

  before_save :extract_dimensions

  if APP_CONFIG.delayed_image_processing
    process_in_background :image, :processing_image_url => "/assets/listing_image/processing.png"
  end
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 8.megabytes
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]
                                    #the two last types are sent by IE.

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  # https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions
  def extract_dimensions
    tempfile = image.queued_for_write[:original]

    # Works with uploaded files and existing files
    file = if tempfile.nil? then image else tempfile end

    geometry = Paperclip::Geometry.from_file(file)
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
  end

  def portrait?
    if self.height && self.width then
      self.height > self.width
    else
      # Default to landscape
      false
    end
  end

  def landscape?
    !portrait?
  end

  def aspect_ratio?(aspect_ratio)
    # Very naive implementation
    # This may need some roundings since we're doing
    # floating point operations here
    (self.width / self.height) == aspect_ratio
  end

end
