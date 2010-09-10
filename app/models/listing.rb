class Listing < ActiveRecord::Base
  
  scope :requests, where(:listing_type => 'request')
  scope :offers, where(:listing_type => 'offer')
  
  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  
  acts_as_taggable_on :tags
  
  # TODO: these should help to use search with tags, but not yet working
  # has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableOn::Tagging",
  #             :conditions => "taggings.taggable_type = 'Listing'"
  # #for context-dependent tags:
  # has_many :tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag",
  #           :conditions => "taggings.context = 'tags'"
  
  has_many :listing_images, :dependent => :destroy
  accepts_nested_attributes_for :listing_images, :reject_if => lambda { |t| t['image'].blank? }
  
  has_many :conversations
  
  has_many :comments
  
  has_many :share_types
  
  scope :requests, :conditions => { :listing_type => 'request' }, :include => :listing_images, :order => "id DESC"
  scope :offers, :conditions => { :listing_type => 'offer' }, :include => :listing_images, :order => "id DESC"
  
  scope :open, :conditions => ["open = '1' AND (valid_until IS NULL OR valid_until > ?)", DateTime.now]
  
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
  
  before_validation :set_rideshare_title, :set_valid_until_time
  
  before_save :downcase_tags
  
  validates_presence_of :author_id
  validates_length_of :title, :in => 2..100, :allow_nil => false
  validates_length_of :origin, :destination, :in => 2..48, :allow_nil => false, :if => :rideshare?
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_inclusion_of :listing_type, :in => VALID_TYPES
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  validates_inclusion_of :valid_until, :allow_nil => :true, :in => DateTime.now..DateTime.now + 1.year 
  validate :given_share_type_is_one_of_valid_share_types
  validate :valid_until_is_not_nil
  
  # Index for sphinx search
  define_index do
    # fields
    indexes title
    indexes description
    # TODO: these should help to use search with tags, but not yet working
    #indexes tags.name, :as => :tags
    #indexes tags(:name), :as => :tags
    
    # attributes
    has created_at, updated_at
    # TODO: these should help to use search with tags, but not yet working
    #has tags(:id), :as => :tag_ids, :facet => true
    
    set_property :enable_star => true
    set_property :delta => true
    set_property :field_weights => {
      :title => 10,
      :tags    => 8,
      :description => 3
    }
  end
  
  def share_type_attributes=(attributes)
    share_types.clear
    attributes.each { |name| share_types.build(:name => name) } if attributes
  end
  
  def downcase_tags
    tag_list.each { |t| t.downcase! }
  end
  
  def rideshare?
    category.eql?("rideshare")
  end
  
  def set_rideshare_title
    if rideshare?
      self.title = "#{origin} - #{destination}" 
    end  
  end
  
  def set_valid_until_time
    if valid_until
      self.valid_until = valid_until.utc + 23.hours + 59.minutes + 59.seconds unless category.eql?("rideshare")
    end  
  end
  
  def default_share_type?(share_type)
    share_type.eql?(Listing::VALID_SHARE_TYPES[listing_type][category].first)
  end
  
  def given_share_type_is_one_of_valid_share_types
    if ["favor", "rideshare"].include?(category)
      errors.add(:share_types, errors.generate_message(:share_types, :must_be_nil)) unless share_types.empty?
    elsif share_types.empty?
      errors.add(:share_types, errors.generate_message(:share_types, :blank)) 
    elsif listing_type && category && VALID_TYPES.include?(listing_type) && VALID_CATEGORIES.include?(category)
      share_types.each do |test_type|
        unless VALID_SHARE_TYPES[listing_type][category].include?(test_type.name)
          errors.add(:share_types, errors.generate_message(:share_types, :inclusion))
        end   
      end
    end  
  end
  
  def self.unique_share_types(listing_type)
    share_types = []
    VALID_CATEGORIES.each do |category|
      if VALID_SHARE_TYPES[listing_type][category] 
        VALID_SHARE_TYPES[listing_type][category].each do |share_type|
          share_types << share_type
        end
      end  
    end     
    share_types.uniq!.sort
  end
  
  def valid_until_is_not_nil
    if (rideshare? || listing_type.eql?("request")) && !valid_until
      errors.add(:valid_until, "cannot be empty")
    end  
  end
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '_').downcase}"
  end
  
  def self.find_with(params)
    conditions = []
    conditions[0] = "listing_type = ?"
    conditions[1] = params[:listing_type]
    if params[:category] && !params[:category][0].eql?("all") 
      conditions[0] += " AND category IN (?)"
      conditions << params[:category]
    end
    if params[:share_type] && !params[:share_type][0].eql?("all")
      where(conditions).joins(:share_types).where(['name IN (?)', params[:share_type]]).group(:listing_id).order("listings.id DESC")
    else
      where(conditions).order("id DESC")
    end    
  end
  
  # Returns true if listing exists and valid_until is set
  def temporary?
    !new_record? && valid_until
  end
  
  def update_fields(params)
    update_attribute(:valid_until, nil) unless params[:valid_until]
    update_attributes(params)
  end
  
  def closed?
    !open? || (valid_until && valid_until < DateTime.now)
  end
  
  def has_share_type?(share_type)
    !share_types.find_by_name(share_type).nil?
  end
  
  def self.opposite_type(type)
    type.eql?("offer") ? "request" : "offer"
  end
  
end