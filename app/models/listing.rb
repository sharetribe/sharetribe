class Listing < ActiveRecord::Base
  
  #Options for status
  VALID_STATUS =  ["open", "in_progress", "closed"]
  
  #allowed language codes
  VALID_LANGUAGES = ["fin", "swe", "eng"]
  
  has_many :comments
  has_many :messages
  belongs_to :category
  belongs_to :person
  
  validates_presence_of :author_id, :category_id, :title, :content, :good_thru, :status, :language

  validates_inclusion_of :status, :in => VALID_STATUS
  validates_inclusion_of :language, :in => VALID_LANGUAGES
  
  validates_length_of :title, :within => 2..50
  validates_length_of :value_other, :allow_nil => true, :allow_blank => true, :maximum => 50
  
  validates_numericality_of :times_viewed, :value_cc, :only_integer => true, :allow_nil => true
  
  #validation of category_id should be done when the category model is made. 
  #It should be limited between the first of the ids and the last of the ids. 
  #MIN = find_by_id(:category, :first) or something like that
  
  #a method for incrementing times_viewed could be done maybe....?
  
end
