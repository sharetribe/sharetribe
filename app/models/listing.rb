class Listing < ActiveRecord::Base
  
  include ApplicationHelper
  include ActionView::Helpers::TranslationHelper
  include Rails.application.routes.url_helpers
  
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
  has_many :notifications, :as => :notifiable, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  has_one :location, :dependent => :destroy
  has_one :origin_loc, :class_name => "Location", :conditions => ['location_type = ?', 'origin_loc'], :dependent => :destroy
  has_one :destination_loc, :class_name => "Location", :conditions => ['location_type = ?', 'destination_loc'], :dependent => :destroy
  accepts_nested_attributes_for :origin_loc, :destination_loc

  has_and_belongs_to_many :communities
  has_and_belongs_to_many :followers, :class_name => "Person", :join_table => "listing_followers"

  belongs_to :category  
  belongs_to :share_type

  monetize :price_cents, :allow_nil => true
  
  attr_accessor :current_community_id
  
  scope :public, :conditions  => "privacy = 'public'"
  scope :private, :conditions  => "privacy = 'private'"

  VALID_VISIBILITIES = ["this_community", "all_communities"]
  VALID_PRIVACY_OPTIONS = ["private", "public"]
  
  LISTING_ICONS = {
    "offer" => "ss-share",
    "request" => "ss-tip",
    "item" => "ss-box",
    "favor" => "ss-heart",
    "rideshare" => "ss-car",
    "housing" => "ss-warehouse",
    "other" => "ss-file",
    "tools" => "ss-wrench",
    "sports" => "ss-tabletennis",
    "music" => "ss-music",
    "books" => "ss-book",
    "games" => "ss-fourdie",
    "furniture" => "ss-lodging",
    "outdoors" => "ss-campfire",
    "food" => "ss-sidedish",
    "electronics" => "ss-smartphone",
    "pets" => "ss-tropicalfish",
    "film" => "ss-moviefolder",
    "clothes" => "ss-hanger",
    "garden" => "ss-tree",
    "travel" => "ss-departure",
    "give_away" => "ss-gift",
    "share_for_free" => "ss-gift",
    "accept_for_free" => "ss-gift",
    "lend" => "ss-flowertag",
    "borrow" => "ss-flowertag",
    "offer_to_swap" => "ss-reload",
    "request_to_swap" => "ss-reload",
    "buy" => "ss-moneybag",
    "sell" => "ss-moneybag",
    "rent" => "ss-pricetag",
    "rent_out" => "ss-pricetag",
    "job" => "ss-briefcase",
    "announcement" => "ss-newspaper",
    "news" => "ss-newspaper",
    "wood_based_materials" => "ss-tree",
    "plastic_and_rubber" => "ss-disc",
    "metal" => "ss-handbag",
    "concrete_and_brick" => "ss-form",
    "glass_and_porcelain" => "ss-fragile",
    "textile_and_leather" => "ss-hanger",
    "soil_materials" => "ss-cloud",
    "liquid_materials" => "ss-droplet",
    "manufacturing_error_materials" => "ss-wrench",
    "misc_material" => "ss-box",
    "clothing" => "ss-hanger",
    "accessories" => "ss-handbag",
    "designers" => "ss-star",
    "mealsharing" => "ss-sidedish",
    "activities" => "ss-usergroup",
    "accommodation" => "ss-lodging",
    "search_material" => "ss-search",
    "sell_material" => "ss-moneybag",
    "give_away_material" => "ss-gift"
  }
  
  before_validation :set_rideshare_title, :set_valid_until_time
  before_save :downcase_tags, :set_community_visibilities
  
  validates_presence_of :author_id
  validates_length_of :title, :in => 2..60, :allow_nil => false
  validates_length_of :origin, :destination, :in => 2..48, :allow_nil => false, :if => :rideshare?

  before_validation do
    # Normalize browser line-breaks.
    # Reason: Some browsers send line-break as \r\n which counts for 2 characters making the 
    # 5000 character max length validation to fail.
    # This could be more general helper function, if this is needed in other textareas.
    self.description = description.gsub("\r\n","\n") if self.description
  end
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  # TODO: validate with community specific details
  # validates_inclusion_of :listing_type, :in => VALID_TYPES
  # validates_inclusion_of :category, :in => VALID_CATEGORIES
  # validate :given_share_type_is_one_of_valid_share_types
  validates_inclusion_of :visibility, :in => VALID_VISIBILITIES
  validates_presence_of :category
  validates_presence_of :share_type
  validates_inclusion_of :valid_until, :allow_nil => :true, :in => DateTime.now..DateTime.now + 7.months
  validates_numericality_of :price_cents, :only_integer => true, :greater_than_or_equal_to => 0, :message => "price must be numeric", :allow_nil => true
  validate :valid_until_is_not_nil
  
  # Index for sphinx search
  define_index do
    
    # limit to open listings
    where "open = '1' AND (valid_until IS NULL OR valid_until > now())"
    
    # fields
    indexes title
    indexes description
    indexes taggings.tag.name, :as => :tags
    indexes comments.content, :as => :comments
    indexes category.translations.name, :as => :category
    # indexes field_values.text_value :as => :custom_text_fields
    
    # attributes
    has created_at, updated_at
    has category(:id), :as => :category_id
    has share_type(:id), :as => :share_type_id 
    has "privacy = 'public'", :as => :visible_to_everybody, :type => :boolean
    has "open = '1' AND (valid_until IS NULL OR valid_until > now())", :as => :open, :type => :boolean
    has communities(:id), :as => :community_ids
    # Fields.each do |field|
    #   has field_values.selected_options.option_id :as => "#options_ids_for_field_{field.id}"
    # end
    
    set_property :enable_star => true
    if APP_CONFIG.FLYING_SPHINX_API_KEY
      set_property :delta => false # try to get sphinx working  FlyingSphinx::DelayedDelta
    else
      set_property :delta => true
    end
    
    set_property :field_weights => {
      :title       => 10,
      :category    => 8,
      :tags        => 8,
      :description => 3,
      :comments    => 1
    }
  end
  
  def set_community_visibilities
    if current_community_id
      communities.clear
      if visibility.eql?("this_community")
        communities << Community.find(current_community_id)
      else
        author.communities.each { |c| communities << c }
      end
    end
  end
  
  # Filter out listings that current user cannot see
  def self.visible_to(current_user, current_community, ids=nil)
    id_condition = ids ? ids : "SELECT listing_id FROM communities_listings WHERE community_id = '#{current_community.id}'"
    if current_user && current_user.member_of?(current_community)
      where("listings.id IN (#{id_condition})")
    else 
      where("listings.privacy = 'public' AND listings.id IN (#{id_condition})")
    end
  end
  
  def self.requests
    with_share_type_or_its_children("request")
  end
  
  def self.offers
    with_share_type_or_its_children("offer")
  end
  
  def self.with_share_type_or_its_children(share_type)
    share_type = ShareType.find_by_name(share_type) unless share_type.class == ShareType
    joins(:share_type).where({:share_types => {:id => share_type.with_all_children.collect(&:id)}})
  end
  
  def self.rideshare
    with_category_or_its_children("rideshare")
  end
  
  def self.with_category_or_its_children(category)
    category = Category.find_by_name(category) unless category.class == Category
    joins(:category).where({:categories => {:id => category.with_all_children.collect(&:id)}})
  end
  
  def self.currently_open(status="open")
    status = "open" if status.blank?
    case status
    when "all"
      where([])
    when "open"  
      where(["open = '1' AND (valid_until IS NULL OR valid_until > ?)", DateTime.now])
    when "closed"
      where(["open = '0' OR (valid_until IS NOT NULL AND valid_until < ?)", DateTime.now])
    end
  end
  
  def visible_to?(current_user, current_community)
    if current_user && current_community
      Listing.count_by_sql("
        SELECT count(*) 
        FROM community_memberships, communities_listings 
        WHERE community_memberships.person_id = '#{current_user.id}' 
        AND community_memberships.community_id = communities_listings.community_id
        AND communities_listings.listing_id = '#{id}'
        AND communities_listings.community_id = '#{current_community.id}'
      ") > 0
    elsif current_community
      return current_community.listings.include?(self) && public? && !closed?
    elsif current_user
      return true if self.privacy.eql?("public")
      self.communities.each do |community|
        return true if current_user.communities.include?(community)
      end
      return false #if user doesn't belong to any community where listing is visible
    else #if no user or community specified, return if visible to anyone
      return public?
    end
  end
  
  def public?
    self.privacy.eql?("public")
  end
  
  # Get only listings that are restricted only to the members of the current 
  # community (or to many communities including current)
  def self.private_to_community(community)
    where("
      listings.privacy = 'private'
      AND listings.id IN (SELECT listing_id FROM communities_listings WHERE community_id = '#{community.id}')
    ")
  end
  
  def downcase_tags
    tag_list.each { |t| t.downcase! }
  end
  
  def rideshare?
    category && category.name.eql?("rideshare")
  end
  
  def set_rideshare_title
    if rideshare?
      self.title = "#{origin} - #{destination}" 
    end  
  end
  
  # sets the time to midnight (unless rideshare listing, where exact time matters)
  def set_valid_until_time
    if valid_until
      self.valid_until = valid_until.utc + (23-valid_until.hour).hours + (59-valid_until.min).minutes + (59-valid_until.sec).seconds unless category && category.name.eql?("rideshare")
    end  
  end
  
  def valid_until_is_not_nil
    if !rideshare? && share_type.is_request? && !valid_until
      errors.add(:valid_until, "cannot be empty")
    end  
  end
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '-').downcase}"
  end
  
  def self.find_with(params, current_user=nil, current_community=nil, per_page=100, page=1)
    params ||= {}  # Set params to empty hash if it's nil
    joined_tables = []
        
    params[:include] ||= [:listing_images, :category, :share_type]
        
    params.reject!{ |key,value| (value == "all" || value == ["all"]) && key != "status"} # all means the fliter doesn't need to be included (except with "status")

    # If no Share Type specified, use listing_type param if that is specified.
    params[:share_type] ||= params[:listing_type]
    params.delete(:listing_type) # In any case listing_type is not a search param used any more

    params[:search] ||= params[:q] # Read search query also from q param
    
    if params[:category]
      category = Category.find_by_name(params[:category])
      if category
        params[:categories] = {:id => category.with_all_children.collect(&:id)} 
        joined_tables << :category
      else
        # ignore the category attribute if it's not found
      end
    end
    
    if params[:share_type]   
      share_type = ShareType.find_by_name(params[:share_type])
      if share_type
        params[:share_types] = {:id => share_type.with_all_children.collect(&:id)}
        joined_tables << :share_type
      else
        # Ignore share_type if not found
        # response.status = :bad_request
        # render :json => ["Share type '#{params["share_type"]}' not found."] and return
      end
    end
    
    
    # Two ways of finding, with or without sphinx
    if params[:search].present? || params[:share_type].present? || params[:category].present?
      
      # sort by time by default
      params[:sort] ||= 'created_at DESC'
      
      with = {}
      if params[:status] == "open" || params[:status].nil?
        with[:open] = true 
      elsif params[:status] == "closed"
        with[:open] = false
      end
      
      unless current_user && current_user.communities.include?(current_community)
        with[:visible_to_everybody] = true
      end
      with[:community_ids] = current_community.id

      with[:category_id] = params[:categories][:id] if params[:categories].present?
      with[:share_type_id] = params[:share_types][:id] if params[:share_types].present?
            
      listings = Listing.search(params[:search],
                                :include => params[:include], 
                                :page => page,
                                :per_page => per_page, 
                                :star => true,
                                :with => with,
                                :order => params[:sort]
                                )
                                
                                
    else # No search query or filters used, no sphinx needed
      query = {}
      query[:categories] = params[:categories] if params[:categories]
      query[:share_types] = params[:share_types] if params[:share_types]
      query[:author_id] = params[:person_id] if params[:person_id]    # this is not yet used with search
      listings = joins(joined_tables).where(query).currently_open(params[:status]).visible_to(current_user, current_community).includes(params[:include]).order("listings.created_at DESC").paginate(:per_page => per_page, :page => page)
    end
    return listings
  end
  
  def self.find_category_and_share_type_based_on_string_params(p)
    p[:category] = Category.find_by_name(p[:subcategory] || p[:category])
    p[:share_type] = ShareType.find_by_name(p[:share_type])
    
    # If there's no specific Share Type defined, use the listing_type param for the "top level share type"
    if p[:share_type].nil?
      p[:share_type] = ShareType.find_by_name(p[:listing_type])
    end
    
    p.delete(:listing_type) # Remove old style listing_type from params
    
    return p
  end
  
  # Listing type is not anymore stored separately, so we serach it by share_type top level parent
  # And return a string here, as that's what expected in most existing cases (e.g. translation strings)
  def listing_type
    return nil if share_type.nil?
    return share_type.top_level_parent.transaction_type || share_type.top_level_parent.name
  end
  
  # Returns true if listing exists and valid_until is set
  def temporary?
    !new_record? && valid_until
  end
  
  def update_fields(params)
    params = Listing.find_category_and_share_type_based_on_string_params(params)
    update_attribute(:valid_until, nil) unless params[:valid_until]
    update_attributes(params)
  end
  
  def closed?
    !open? || (valid_until && valid_until < DateTime.now)
  end

  def self.opposite_type(type)
    type.eql?("offer") ? "request" : "offer"
  end
  
  def self.opposite_share_type(type)
    return "" if type.nil?
    st = type.class.eql?(String) ? type : type.name
    case st
    when "borrow"
      return "lend"
    when "lend"
      return "borrow"
    when "buy"
      return "sell"
    when "sell"
      return "buy"
    when "rent_out"
      return "rent"
    when "rent"
      return "rent_out"
    else
      return "" 
    end
  end
  
  # Returns true if the given person is offerer and false if requester
  def offerer?(person)
    (share_type.is_offer? && author.eql?(person)) || (share_type.is_request? && !author.eql?(person))
  end
  
  # Returns true if the given person is requester and false if offerer
  def requester?(person)
    (share_type.is_request? && author.eql?(person)) || (share_type.is_offer? && !author.eql?(person))
  end
  
  def selling_or_renting?
    does_not_have_any_of_share_types?(["request_to_swap", "offer_to_swap", "lend", "give_away"])
  end
  
  def lending_or_giving_away?
    does_not_have_any_of_share_types?(["sell", "rent_out", "request_to_swap", "offer_to_swap"])
  end
  
  def does_not_have_any_of_share_types?(sts)
    return_value = true
    sts.each { |st| return_value = false if share_type.eql?(st) }
    return return_value
  end
  
  # If listing is an offer, a discussion about the listing
  # should be request, and vice versa
  def discussion_type
    share_type.is_request? ? "offer" : "request"
  end
  
  # This is used to provide clean JSON-strings for map view queries
  def as_json(options = {})
    
    # This is currently optimized for the needs of the map, so if extending, make a separate JSON mode, and keep map data at minimum
    hash = {
      :listing_type => self.listing_type,
      :category => self.category.name,
      :id => self.id,
      :icon => icon_class(icon_name)
    }
    if self.origin_loc
      hash.merge!({:latitude => self.origin_loc.latitude,
                  :longitude => self.origin_loc.longitude})
    end
    return hash
  end
  
  # Send notifications to the users following this listing
  # when the listing is updated (update=true) or a
  # new comment to the listing is created.
  def notify_followers(community, current_user, update)
    followers.each do |follower|
      unless follower.id == current_user.id
        if update
          Notification.create(:notifiable_id => self.id, :notifiable_type => "Listing", :receiver_id => follower.id, :description => "updated")
          PersonMailer.new_update_to_followed_listing_notification(self, follower, community).deliver
        else
          Notification.create(:notifiable_id => comments.last.id, :notifiable_type => "Comment", :receiver_id => follower.id, :description => "to_followed_listing")
          PersonMailer.new_comment_to_followed_listing_notification(comments.last, follower, community).deliver
        end
      end
    end
  end
  
  def has_image?
    !listing_images.empty?
  end
  
  def icon_name
    category.icon_name
  end
  
  # The price symbol based on this listing's price or community default, if no price set
  def price_symbol
    price ? price.symbol : MoneyRails.default_currency.symbol
  end
  
  def transaction_type
    share_type.top_level_parent.transaction_type
  end
  
  def price_with_vat(vat)
    price + (price * vat / 100)
  end
  
end
