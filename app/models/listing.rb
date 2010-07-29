class Listing < ActiveRecord::Base
  
  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  
  acts_as_taggable
  
  has_many :listing_images, :dependent => :destroy
  accepts_nested_attributes_for :listing_images, :reject_if => lambda { |t| t['image'].nil? }
  
  VALID_TYPES = ["offer", "request"]
  VALID_CATEGORIES = ["item", "favor", "rideshare", "housing"]
  VALID_SHARE_TYPES = {
    "offer" => {
      "item" => ["lend", "sell", "rent_out", "trade", "give_away"],
      "favor" => nil, 
      "rideshare" => nil,
      "housing" => ["rent_out", "sell", "temporary_accommodation"]
    },
    "request" => {
      "item" => ["borrow", "buy", "rent", "trade"],
      "favor" => nil, 
      "rideshare" => nil,
      "housing" => ["rent", "buy", "temporary_accommodation"],
    }
  }
  
  serialize :share_type, Array
  
  before_validation :set_rideshare_title
  
  validates_presence_of :author_id
  validates_length_of :title, :in => 2..100, :allow_nil => false
  validates_length_of :origin, :destination, :in => 2..48, :allow_nil => false, :if => :rideshare?
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_inclusion_of :listing_type, :in => VALID_TYPES
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  validate :given_share_type_is_one_of_valid_share_types
  
  def rideshare?
    category.eql?("rideshare")
  end
  
  def set_rideshare_title
    if rideshare?
      self.title = "#{origin} - #{destination}" 
    end  
  end
  
  def default_share_type?(share_type)
    share_type.eql?(Listing::VALID_SHARE_TYPES[listing_type][category].first)
  end
  
  def self.unique_share_types
    share_types = []
    VALID_TYPES.each do |type|
      VALID_CATEGORIES.each do |category|
        if VALID_SHARE_TYPES[t]
          VALID_SHARE_TYPES[type][category].each do |share_type|
            share_types << share_type
          end
        end  
      end
    end      
    share_types.uniq!    
  end
  
  def given_share_type_is_one_of_valid_share_types
    if ["favor", "rideshare"].include?(category)
      if share_type
        errors.add(:share_type, "is not used for this category")
      end
    elsif !share_type
      errors.add(:share_type, "must be selected") 
    elsif listing_type && category && share_type && VALID_TYPES.include?(listing_type) && VALID_CATEGORIES.include?(category)
      share_type.each do |test_type|
        unless VALID_SHARE_TYPES[listing_type][category].include?(test_type)
          errors.add(:share_type, "is not included in the list")
        end   
      end
    end  
  end
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '_').downcase}"
  end
  
end  