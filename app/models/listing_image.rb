class ListingImage < ActiveRecord::Base
  
  belongs_to :listing
  
  has_attached_file :image, :styles => { 
        :medium => "360x270#",
        :thumb => "120x120#",
        :original => "1600x1600>",
        :big => "800x800>",
        :big_cropped => Proc.new { |instance| instance.crop_big },
        :email => "150x100#"
    }

  def crop_big
    geometry = Paperclip::Geometry.from_file(Paperclip.io_adapters.for(image.queued_for_write[:original]))
    max_landscape_crop_percentage = 0.2
    ListingImage.construct_big_style({:width => geometry.width.round, :height => geometry.height.round}, max_landscape_crop_percentage)
  end
  
  if APP_CONFIG.delayed_image_processing
    process_in_background :image, :processing_image_url => "/assets/listing_image/processing.png" 
  end
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 8.megabytes
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]
                                    #the two last types are sent by IE. 

  def self.portrait?(dimensions)
    dimensions[:height] > dimensions[:width]
  end

  def self.scale_height_down(dimensions, desired_height)
    if dimensions[:height] > desired_height
      scale_factor = dimensions[:height] / desired_height.to_f
      {
        :width => (dimensions[:width] / scale_factor).round,
        :height => (dimensions[:height] / scale_factor).round
      }
    else
      dimensions
    end
  end

  # Assumes:
  # - Landscape image
  # - Height is scaled already
  def self.crop_landscape_sides(dimensions, desired_width, max_crop_percentage)
    crop_need = dimensions[:width] - desired_width
    crop_need_percentage = crop_need.to_f / dimensions[:width]

    if(crop_need_percentage <= max_crop_percentage)
      {:width => desired_width, :height => dimensions[:height]}
    else
      cropped_width = ((1 - max_crop_percentage) * dimensions[:width]).round
      {:width => cropped_width, :height => dimensions[:height]}
    end
  end

  def self.construct_big_style(dimensions, max_landscape_crop_percentage)
    default = "660x440>"

    if self.portrait? dimensions
      default
    else
      scaled = self.scale_height_down(dimensions, 440)
      cropped = self.crop_landscape_sides(scaled, 660, 0.2)

      "#{cropped[:width]}x#{cropped[:height]}#"
    end
  end
end
