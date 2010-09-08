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
  
  scope :requests, :conditions => { :listing_type => 'request' }, :order => "id DESC"
  scope :offers, :conditions => { :listing_type => 'offer' }, :order => "id DESC"
  
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
  
  def downcase_tags
    tag_list.each { |t| t.downcase! }
    logger.info "Tag list: #{tag_list}"
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
      if share_type
        errors.add(:share_type, errors.generate_message(:share_type, :must_be_nil))
      end
    elsif !share_type
      errors.add(:share_type, errors.generate_message(:share_type, :blank)) 
    elsif listing_type && category && share_type && VALID_TYPES.include?(listing_type) && VALID_CATEGORIES.include?(category)
      share_type.each do |test_type|
        unless VALID_SHARE_TYPES[listing_type][category].include?(test_type)
          errors.add(:share_type, errors.generate_message(:share_type, :inclusion))
        end   
      end
    end  
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
    where(conditions).order("id DESC")
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
    status.eql?("closed") || valid_until < DateTime.now
  end
  
end  