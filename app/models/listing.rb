class Listing < ActiveRecord::Base
  
  #Options for status
  VALID_STATUS =  ["open", "in_progress", "closed"]
  
  #allowed language codes
  VALID_LANGUAGES = ["fin", "swe", "eng"]
  
  VALID_CATEGORIES = ["market_place", "borrow_items", "rides", "groups", "favors", "others", "sell", "buy", "give"]
  
  has_many :comments
  has_many :messages
  #category model is not gonnna happen anymore
  #belongs_to :category
  belongs_to :person
  
  validates_presence_of :author_id, :category, :title, :content, :good_thru, :status, :language

  validates_inclusion_of :status, :in => VALID_STATUS
  validates_inclusion_of :language, :in => VALID_LANGUAGES
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  
  validates_length_of :title, :within => 2..50
  validates_length_of :value_other, :allow_nil => true, :allow_blank => true, :maximum => 50
  
  validates_numericality_of :times_viewed, :value_cc, :only_integer => true, :allow_nil => true
  
  #a method for incrementing times_viewed could be done maybe....?
  
end
