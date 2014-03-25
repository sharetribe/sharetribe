class ListingImage < ActiveRecord::Base

  belongs_to :listing
  belongs_to :author, :class_name => "Person"
  
  has_attached_file :image, :styles => {
        :small_3x2 => "240x160#",
        :medium => "360x270#",
        :thumb => "120x120#",
        :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>",
        :big => "800x800>",
        :email => "150x100#"}

  before_save :extract_dimensions

  process_in_background :image, :processing_image_url => "/assets/listing_image/processing.png"
  validates_attachment_size :image, :less_than => APP_CONFIG.max_image_filesize, :unless => Proc.new {|model| model.image.nil? }
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"], # the two last types are sent by IE.
                                    :unless => Proc.new {|model| model.image.nil? }

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  # https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions
  def extract_dimensions
    return unless image?
    tempfile = image.queued_for_write[:original]

    # Silently return, if there's no `width` and `height`
    # Prevents old migrations from crashing
    return unless self.respond_to?(:width) && self.respond_to?(:height)

    # Works with uploaded files and existing files
    path_or_url = if !tempfile.nil? then
      # Uploading new file
      tempfile.path
    else
      if image.options[:storage] === :s3
        image.url
      else
        image.path
      end
    end

    geometry = Paperclip::Geometry.from_file(path_or_url)
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
  end

  def authorized?(user)
    author == user || (listing && listing.author == user)
  end

  def correct_size?(aspect_ratio)
    ListingImage.correct_size? self.width, self.height, aspect_ratio
  end

  def too_narrow?(aspect_ratio)
    ListingImage.too_narrow? self.width, self.height, aspect_ratio
  end

  def too_wide?(aspect_ratio)
    ListingImage.too_wide? self.width, self.height, aspect_ratio
  end

  def self.correct_size?(width, height, aspect_ratio)
    width.to_f / height.to_f == aspect_ratio.to_f
  end

  def self.too_narrow?(width, height, aspect_ratio)
    width.to_f / height.to_f < aspect_ratio.to_f
  end

  def self.too_wide?(width, height, aspect_ratio)
    width.to_f / height.to_f > aspect_ratio.to_f
  end

  def download_from_url(url)
    self.image = URI.parse(url)
    self.update_attribute(:image_downloaded, true)
  end
end
