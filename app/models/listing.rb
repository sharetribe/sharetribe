class Listing < ActiveRecord::Base
  
  has_many :messages
  has_many :comments
  
  serialize :language, Array
  
  #Options for status
  VALID_STATUS =  ["open", "in_progress", "closed"]
  
  #allowed language codes
  VALID_LANGUAGES = ["fi", "swe", "en-US"]
  
  VALID_CATEGORIES = ["borrow_items", "lost_property", "rides", "groups", "favors", "others", "sell", "buy", "give"]
  
  has_many :comments
  has_many :messages
  belongs_to :person

  attr_accessor :language_fi, :language_en, :language_swe
  
  validates_presence_of :author_id, :category, :title, :content, :good_thru, :status, :language

  validates_inclusion_of :status, :in => VALID_STATUS
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  validates_inclusion_of :good_thru, :on => :create, :allow_nil => true, 
                         :in => DateTime.now..DateTime.now + 1.year
  
  validates_length_of :title, :within => 2..50
  validates_length_of :value_other, :allow_nil => true, :allow_blank => true, :maximum => 50
  
  validates_numericality_of :times_viewed, :value_cc, :only_integer => true, :allow_nil => true
  
  validate :given_language_is_one_of_valid_languages

  def given_language_is_one_of_valid_languages
    unless language.nil?
      language.each do |test_language|
        errors.add(:language, "should be one of the valid ones") if !VALID_LANGUAGES.include?(test_language)
      end
    end  
  end

end
