class ListingImage < ActiveRecord::Base

  belongs_to :listing
  has_attached_file :image, 
      :styles => { :medium => "300x640>", :thumb => "85x85#", :original => "640x640>" },
      :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
      :url => "/system/:attachment/:id/:style/:filename"
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]
                                    #the two last types are sent by IE. 

end
