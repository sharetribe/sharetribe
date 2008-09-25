class PersonInterestingListing < ActiveRecord::Base
  belongs_to :person
  belongs_to :listing
  
  validates_presence_of :person_id, :listing_id
end
