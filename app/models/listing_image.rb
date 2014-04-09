class ListingImage < ActiveRecord::Base

  belongs_to :listing
  belongs_to :author, :class_name => "Person"

  has_attached_file :image, :styles => {
        :small_3x2 => "240x160#",
        :medium => "360x270#",
        :thumb => "120x120#",
        :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>",
        :big => Proc.new { |instance| instance.crop_big },
        :email => "150x100#"}

  before_save :set_dimensions!

  process_in_background :image, :processing_image_url => "/assets/listing_image/processing.png"
  validates_attachment_size :image, :less_than => APP_CONFIG.max_image_filesize.to_i, :unless => Proc.new {|model| model.image.nil? }
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"], # the two last types are sent by IE.
                                    :unless => Proc.new {|model| model.image.nil? }


  def set_dimensions!
    # Silently return, if there's no `width` and `height`
    # Prevents old migrations from crashing
    return unless self.respond_to?(:width) && self.respond_to?(:height)

    geometry = extract_dimensions

    if geometry
      self.width = geometry.width.to_i
      self.height = geometry.height.to_i
    end
  end

  def crop_big
    geometry = Paperclip::Geometry.from_file(Paperclip.io_adapters.for(image.queued_for_write[:original]))
    max_landscape_crop_percentage = 0.2
    ListingImage.construct_big_style({:width => geometry.width.round, :height => geometry.height.round}, max_landscape_crop_percentage)
  end

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  # https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions
  def extract_dimensions
    return unless image_ready?
    tempfile = image.queued_for_write[:original]

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

  def image_ready?
    image_downloaded && !image_processing
  end

  def self.crop_need(x, desired_x)
    x - desired_x
  end

  def self.crop_need_percentage(x, desired_x)
    self.crop_need(x, desired_x).to_f / x.to_f
  end

  def self.should_crop?(dimensions, desired_dimensions, max_crop_difference)
    scaled = self.scale_to_cover(dimensions, desired_dimensions)

    width_crop_need = crop_need_percentage(scaled[:width], desired_dimensions[:width])
    height_crop_need = crop_need_percentage(scaled[:height], desired_dimensions[:height])

    width_crop_need <= max_crop_difference && height_crop_need <= max_crop_difference
  end

  def self.scale_by(source, target, by)
    scale_factor = source[by] / target[by].to_f
      {
        :width => (source[:width] / scale_factor),
        :height => (source[:height] / scale_factor)
      }
  end

  def self.scale_to_direction_by(source, target, direction, by)
    scale = direction == :up ? source[by] < target[by] : source[by] > target[by]

    if scale
      scale_by(source, target, by)
    else
      source
    end
  end

  def self.scale_to_direction_cover(dimensions, area_to_cover, direction)
    scaled_width = scale_to_direction_by(dimensions, area_to_cover, direction, :width)
    scaled_width_height = scale_to_direction_by(scaled_width, area_to_cover, direction, :height)
    return scaled_width_height
  end

  def self.scale_direction(dimensions, area_to_cover)
    if dimensions[:width] > area_to_cover[:width] && dimensions[:height] > area_to_cover[:height]
      :down
    else
      :up
    end
  end

  def self.scale_to_cover(dimensions, area_to_cover)
    direction = self.scale_direction(dimensions, area_to_cover)
    self.scale_to_direction_cover(dimensions, area_to_cover, direction)
  end

  def self.construct_big_style(dimensions, desired_dimensions, max_crop_difference)
    default_style = "#{desired_dimensions[:width]}x#{desired_dimensions[:height]}>"
    crop_style = "#{desired_dimensions[:width]}x#{desired_dimensions[:height]}#"

    if self.should_crop?(dimensions, desired_dimensions, max_crop_difference)
      crop_style
    else
      default_style
    end
  end
end
