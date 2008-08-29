class Filter < ActiveRecord::Base
  belongs_to :person
  
  serialize :keywords, Array
  
  #if category is nil, filter will concern all categories
  validates_presence_of :person_id, :keywords
  
  validates_inclusion_of :category, :in => Listing.get_valid_categories, :allow_nil => true
  
  #this model allows lower and uppercase keywords but when they are parsed to an array,
  #all letters in those keywords should be converted all to downcase letters for making
  #searches work
      
end
