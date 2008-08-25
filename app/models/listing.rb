class Listing < ActiveRecord::Base
  
  has_many :messages
  has_many :comments, :class_name => "ListingComment"
  
  belongs_to :person
  
  has_many :read_listings
  has_many :persons, :through => :read_listings
  
  has_many :interesting_listings
  has_many :persons, :through => :interesting_listings
  
  serialize :language, Array
  
  #Options for status
  VALID_STATUS =  ["open", "in_progress", "closed"]
  
  #allowed language codes
  VALID_LANGUAGES = ["fi", "swe", "en-US"]
  
  # Categories that can be assigned to a listing.
  VALID_CATEGORIES = ["borrow_items", "lost_property", "rides", "groups", "favors", "others", "sell", "buy", "give"]

  # Main categories (only those that don's contain sub categories are valid listing categories.)
  MAIN_CATEGORIES = ['marketplace', "borrow_items", "lost_property", "rides", "groups", "favors", "others"]

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
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '-').downcase}"
  end
  
  # Get sub categories for a category.
  def self.get_sub_categories(main_category)
    case main_category
    when "marketplace"
      ['sell', 'buy', 'give']
    else
      nil
    end  
  end

end
