class Listing < ActiveRecord::Base
  
  include LocationsHelper
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
  
  has_many :share_types, :dependent => :destroy
  
  attr_accessor :current_community_id
  
  scope :requests, :conditions => { :listing_type => 'request' }, :include => [ :listing_images ], :order => "listings.created_at DESC"
  scope :offers, :conditions => { :listing_type => 'offer' }, :include => [ :listing_images ], :order => "listings.created_at DESC"
  scope :rideshare, :conditions => { :category => "rideshare"}
  
  scope :currently_open, :conditions => ["open = '1' AND (valid_until IS NULL OR valid_until > ?)", DateTime.now]
  scope :public, :conditions  => "privacy = 'public'"
  scope :private, :conditions  => "privacy = 'private'"

  VALID_TYPES = ["offer", "request"]
  VALID_CATEGORIES = ["item", "favor", "rideshare", "housing"]
  VALID_SUBCATEGORIES = {
    "item" => [
      "tools",
      "sports",
      "music",
      "books",
      "games",
      "furniture",
      "outdoors",
      "food",
      "electronics",
      "pets",
      "film",
      "clothes",
      "garden",
      "travel",
      "other"
    ]  
  }
  VALID_SHARE_TYPES = {
    "offer" => {
      "item" => ["lend", "sell", "rent_out", "trade", "give_away"],
      "favor" => nil, 
      "rideshare" => nil,
      "housing" => ["rent_out", "sell", "share_for_free"]
    },
    "request" => {
      "item" => ["borrow", "buy", "rent", "trade", "receive"],
      "favor" => nil, 
      "rideshare" => nil,
      "housing" => ["rent", "buy"],
    }
  }
  VALID_VISIBILITIES = ["this_community", "all_communities"]
  VALID_PRIVACY_OPTIONS = ["private", "public"]
  
  LISTING_ICONS = {
    "offer" => "ss-share",
    "request" => "ss-tip",
    "item" => "ss-suitcase",
    "favor" => "ss-heart",
    "rideshare" => "ss-car",
    "housing" => "ss-warehouse",
    "other" => "ss-page",
    "tools" => "ss-wrench",
    "sports" => "ss-tabletennis",
    "music" => "ss-music",
    "books" => "ss-bookmark",
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
    "lend" => "ss-flowertag",
    "borrow" => "ss-flowertag",
    "trade" => "ss-reload",
    "buy" => "ss-moneybag",
    "sell" => "ss-moneybag",
    "rent" => "ss-pricetag",
    "rent_out" => "ss-pricetag"
  }
  
  before_validation :set_rideshare_title, :set_valid_until_time
  before_save :downcase_tags, :set_community_visibilities
  after_create :check_possible_matches
  
  validates_presence_of :author_id
  validates_length_of :title, :in => 2..90, :allow_nil => false
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
    indexes taggings.tag.name, :as => :tags
    indexes comments.content, :as => :comments
    
    # attributes
    has created_at, updated_at, category
    has "listing_type = 'offer'", :as => :is_offer, :type => :boolean
    has "listing_type = 'request'", :as => :is_request, :type => :boolean
    has "privacy = 'public'", :as => :visible_to_everybody, :type => :boolean
    has "open = '1' AND (valid_until IS NULL OR valid_until > now())", :as => :open, :type => :boolean
    has communities(:id), :as => :community_ids
    
    set_property :enable_star => true
    if APP_CONFIG.FLYING_SPHINX_API_KEY
      set_property :delta => false # try to get sphinx working  FlyingSphinx::DelayedDelta
    else
      set_property :delta => true
    end
    
    set_property :field_weights => {
      :title       => 10,
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
      return current_community.listings.include?(self) && public?
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
  
  # Get only  listings that are private to current community (or to many communities including current)
  def self.private_to_community(community)
    where("
        listings.visibility IN ('communities','this_community') 
        AND listings.id IN (SELECT listing_id FROM communities_listings WHERE community_id = '#{community.id}')
      ")
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
  
  # sets the time to midnight (unless rideshare listing, where exact time matters)
  def set_valid_until_time
    if valid_until
      self.valid_until = valid_until.utc + (23-valid_until.hour).hours + (59-valid_until.min).minutes + (59-valid_until.sec).seconds unless category.eql?("rideshare")
    end  
  end
  
  def given_share_type_is_one_of_valid_share_types
    if ["favor", "rideshare"].include?(category)
       errors.add(:share_type, errors.generate_message(:share_type, :must_be_nil)) unless share_type.nil?
     elsif share_type.nil?
       errors.add(:share_type, errors.generate_message(:share_type, :blank)) 
     elsif listing_type && category && VALID_TYPES.include?(listing_type) && VALID_CATEGORIES.include?(category)
       unless VALID_SHARE_TYPES[listing_type][category].include?(share_type)
         errors.add(:share_type, errors.generate_message(:share_type, :inclusion))
       end
     end  
  end
  
  def self.all_unique_share_types
    share_types = []
    VALID_TYPES.each do |listing_type|
      VALID_CATEGORIES.each do |category|
        if VALID_SHARE_TYPES[listing_type][category] 
          VALID_SHARE_TYPES[listing_type][category].each do |share_type|
            share_types << share_type
          end
        end  
      end
    end
    share_types.uniq!.sort
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
    if !rideshare? && listing_type.eql?("request") && !valid_until
      errors.add(:valid_until, "cannot be empty")
    end  
  end
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '-').downcase}"
  end
  
  def self.find_with(params, current_user=nil, current_community=nil)
    params = params || {}  # Set params to empty hash if it's nil
    conditions = []
    if params[:listing_type] && !params[:listing_type].eql?("all") 
      conditions[0] = "listing_type = ?"
      conditions[1] = params[:listing_type]
    end
    listings = where(conditions)
    if params[:category] && !params[:category][0].eql?("all") 
      listings = listings.where(['category IN (?)', params[:category]])
    end

    if params[:share_type] && !params[:share_type][0].eql?("all")
      listings = listings.where(['share_type IN (?)', params[:share_type]])
    end
    if params[:tag]
      listings = listings.joins(:taggings).where(['tag_id IN (?)', Tag.ids(params[:tag])]).group(:id)
    end 
    listings.visible_to(current_user, current_community).order("listings.created_at DESC")
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

  def self.opposite_type(type)
    type.eql?("offer") ? "request" : "offer"
  end
  
  # Returns true if the given person is offerer and false if requester
  def offerer?(person)
    (listing_type.eql?("offer") && author.eql?(person)) || (listing_type.eql?("request") && !author.eql?(person))
  end
  
  def selling_or_renting?
    does_not_have_any_of_share_types?(["trade", "lend", "give_away"])
  end
  
  def lending_or_giving_away?
    does_not_have_any_of_share_types?(["sell", "rent_out", "trade"])
  end
  
  def does_not_have_any_of_share_types?(sts)
    return_value = true
    sts.each { |st| return_value = false if share_type.eql?(st) }
    return return_value
  end
  
  # If listing is an offer, a discussion about the listing
  # should be request, and vice versa
  def discussion_type
    listing_type.eql?("request") ? "offer" : "request"
  end
  
  # Called after create
  # Checks if there was already an offer matching this request
  # or a request matching this offer
  # Inform the requester if possible match is found
  def check_possible_matches
    logger.info "Checking possible matches for just created rideshare listing."
    timing_tolerance = 1.6.hours # how big difference in starting time is accepted
        
    # currently check only rideshare listings
    return true unless (category == "rideshare" && APP_CONFIG.use_sms)
    
    potential_listings = []
    if listing_type == "request"
      potential_listings =  Listing.currently_open.rideshare.offers
    else
      potential_listings = Listing.currently_open.rideshare.requests
    end
    
    potential_listings.each do |candidate|
      if listing_type == "request"
        if ((valid_until-timing_tolerance..valid_until+timing_tolerance) === (candidate.valid_until) &&
            candidate.origin_and_destination_close_enough?(self))
            
          inform_requester_about_potential_match(self, candidate)
        end
      else
        if ((valid_until-timing_tolerance..valid_until+timing_tolerance) === (candidate.valid_until) &&
            origin_and_destination_close_enough?(candidate))
        
          inform_requester_about_potential_match(candidate, self)
        end
      end
      
    end
    
  end
  
  def origin_and_destination_close_enough?(candidate)
    
    # The Google routing API is used to check
    # how much the offerer's route would be longer if he
    # would pickup the requester. If difference is small it the ride 
    # is suggested to the requester)
    
    # consider origin and destaination being close enough, if the
    # difference between direct journey and with waypoints is 
    # smaller than the tolerance for duration and distance.
    duration_tolerence_percentage = 20
    min_duration_tolerance = 15 # in minutes
    distance_tolerance_percentage = 20
    min_distance_tolerance = 10
    
    # If routing fails, fall back to old solution of comparing strings and posibly geocoded coordinates.
    # This is used by the old method only:
    location_tolerance = 5 # kilometers, the max distance between spots to match them
    
    logger.info "Comparing origin and destinations of #{title} and #{candidate.title}"
    
    
    # Try first with route comparison
    begin
      direct_route = route_duration_and_distance(origin, destination)
      ridesharing_route = route_duration_and_distance(origin, destination, [candidate.origin, candidate.destination])
      duration_difference = ridesharing_route[0] - direct_route[0]
      distance_difference = ridesharing_route[1] - direct_route[1]
      
      logger.info "Result was that difference in duration would be: #{duration_difference} minutes and in distance #{distance_difference} km."
      
      if ((duration_difference < min_duration_tolerance || 
         duration_difference < direct_route[0] * duration_tolerence_percentage * 0.01) &&
         (distance_difference < min_distance_tolerance ||
         distance_difference < direct_route[1] * distance_tolerance_percentage * 0.01))
        return true
      else
        # got valid result from routing, but the difference was too big, so return false.
        return false
      end
    rescue  RuntimeError => e
      logger.info "Error while calculating route: #{e.message}"
      # encountered and error with routing so continue and try the other method
    end
    
    # try second if exact match or closeness by geocoded coordinates is close enough
    begin
      if  (( origin.casecmp(candidate.origin) == 0 || distance_between(get_coordinates(origin), get_coordinates(candidate.origin)) < location_tolerance) && 
          (destination.casecmp(candidate.destination) == 0 || distance_between(get_coordinates(destination), get_coordinates(candidate.destination)) < location_tolerance))
        return true
      else 
        return false
      end
    rescue RuntimeError => e
      logger.info "Error while  geocoding: #{e.message}"
      return false
    end
  end
  
  def inform_requester_about_potential_match(request, offer)
    logger.info "Informing the author of: #{request.title} (starting at #{request.valid_until}) about the possible match of #{offer.title} (starting at #{offer.valid_until})"

    # Check if requester has a phone number and sens sms if sms's are in use
    if APP_CONFIG.use_sms && !request.author.phone_number.blank?

      # send the message in recipients language and use very short date format to fit in sms
      locale = request.author.locale.to_sym || :fi
      Time::DATE_FORMATS[:sms] = I18n.t("time.formats.sms", :locale => locale)
      message = I18n.t("sms.potential_ride_share_offer", :author_name => offer.author.given_name_or_username, :origin => offer.origin, :destination => offer.destination, :start_time  => offer.valid_until.to_formatted_s(:sms), :locale => locale)
      listing_url = ApplicationHelper.shorten_url("http://demo.sharetribe.com/#{locale.to_s}/listings/#{offer.id}")
      unless offer.author.phone_number.blank?
        message += " " + I18n.t("sms.you_can_call_him_at", :phone_number  => offer.author.phone_number, :locale => locale)
        message += " " + I18n.t("sms.or_check_the_offer_in_kassi", :listing_url => listing_url, :locale => locale)
        
      else
        message += " " + I18n.t("sms.check_the_offer_in_kassi", :listing_url => listing_url, :locale => locale)
      end
      message += " " +  I18n.t("sms.you_can_pay_gas_money_to_driver", :driver => offer.author.given_name_or_username, :locale => locale)
      # Here it should be stored somewhere (DB probably) that a payment suggestion is made from potential passenger
      # to the driver (and the time and date of the suggestions)
      # But as there is not yet real payment API, this is not yet implemented.

      SmsHelper.send(message, request.author.phone_number)
    end
  end
  
  # This is used to provide clean JSON-strings for map view queries
  def as_json(options = {})
    # json_dict = {
    #   :listing_type => self.listing_type,
    #   :category => self.category,
    #   :id => self.id,
    #   :latitude => self.origin_loc.latitude,
    #   :longitude => self.origin_loc.longitude
    # }
    # 
    # json_dict[:location] = self.location.as_json if self.location
    # json_dict[:origin_loc] = self.origin_loc.as_json if self.origin_loc
    # json_dict[:destination_loc] = self.destination_loc.as_json if self.destination_loc
    # 
    # json_dict
    
    {
      :listing_type => self.listing_type,
      :category => self.category,
      :id => self.id,
      :latitude => self.origin_loc.latitude,
      :longitude => self.origin_loc.longitude
    }
  end
  
  # Send notifications to the users following this listing
  # when the listing is updated (update=true) or a
  # new comment to the listing is created.
  def notify_followers(host, current_user, update)
    followers.each do |follower|
      unless follower.id == current_user.id
        if update
          Notification.create(:notifiable_id => self.id, :notifiable_type => "Listing", :receiver_id => follower.id, :description => "updated")
          PersonMailer.new_update_to_followed_listing_notification(self, follower, host).deliver
        else
          Notification.create(:notifiable_id => comments.last.id, :notifiable_type => "Comment", :receiver_id => follower.id, :description => "to_followed_listing")
          PersonMailer.new_comment_to_followed_listing_notification(comments.last, follower, host).deliver
        end
      end
    end
  end
  
  def has_image?
    !listing_images.empty?
  end
  
end
