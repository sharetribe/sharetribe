class ListingImage < ActiveRecord::Base
  
  belongs_to :listing
  
  paperclip_options = PaperclipHelper.paperclip_default_options.merge!({:styles => { 
        :medium => "360x270#", 
        :thumb => "120x120#", 
        :original => "1600x1600>",
        :big => "800x800>",
        :email => "150x100#"
  }})

  
  has_attached_file :image, paperclip_options
  if APP_CONFIG.delayed_image_processing
    process_in_background :image, :processing_image_url => "/assets/listing_image/processing.png" 
  end
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 8.megabytes
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]
                                    #the two last types are sent by IE. 

end
