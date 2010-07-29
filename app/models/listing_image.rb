class ListingImage < ActiveRecord::Base

  belongs_to :listing
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "85x85>" }
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 5.megabytes

end
