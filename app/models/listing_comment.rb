class ListingComment < ActiveRecord::Base
  belongs_to :person
  belongs_to :listing
  
  validates_presence_of :author_id, :listing_id
  validates_numericality_of :listing_id, :only_integer => true
end
