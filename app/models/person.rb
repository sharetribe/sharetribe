require 'json'
require 'rest_client'
require 'httpclient'

# This class represents a person (a user of Kassi). Most of the person
# information is stored in ASI that is accessed via PersonConnection class.
# Because the delays in the http requests, we use some caching to store the
# results of the ASI-requests.

class Person < ActiveRecord::Base
  
  include ErrorsHelper
  
  # FIXME: CACHING DISABLED DUE PROBLEMS AT ALPHA SERVER
  PERSON_HASH_CACHE_EXPIRE_TIME = 0#15  #ALSO THIS CACHE TEMPORARILY OFF TO TEST PERFORMANCE WIHTOUT IT
  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours  ## THE CACHE IS TEMPORARILY OFF BECAUSE CAUSED PROBLEMS ON ALPHA: SEE ALSO COMMENTING OUT AT THE PLACE WHER CACHE IS USED!
    
  attr_accessor :guid, :password, :password2, :username, :email, :form_username,
                :form_given_name, :form_family_name, :form_password, 
                :form_password2, :form_email, :consent
  
  attr_protected :is_admin

  has_many :listings, :dependent => :destroy, :foreign_key => "author_id"
  has_many :offers, 
           :foreign_key => "author_id", 
           :class_name => "Listing", 
           :conditions => { :listing_type => "offer" },
           :order => "id DESC"
  has_many :requests, 
           :foreign_key => "author_id", 
           :class_name => "Listing", 
           :conditions => { :listing_type => "request" },
           :order => "id DESC"
  
  has_many :participations, :dependent => :destroy 
  has_many :conversations, :through => :participations
  has_many :authored_testimonials, :class_name => "Testimonial", :foreign_key => "author_id"
  has_many :received_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :order => "id DESC"
  has_many :messages, :foreign_key => "sender_id"
  has_many :badges, :dependent => :destroy 
  has_many :notifications, :foreign_key => "receiver_id", :order => "id DESC"
  has_many :authored_comments, :class_name => "Comment", :foreign_key => "author_id"
  has_many :community_memberships, :dependent => :destroy 
  has_many :communities, :through => :community_memberships
  
  EMAIL_NOTIFICATION_TYPES = [
    "email_about_new_messages",
    "email_about_new_comments_to_own_listing",
    "email_when_conversation_accepted",
    "email_when_conversation_rejected",
    "email_about_new_badges",
    "email_about_new_received_testimonials",
    "email_about_testimonial_reminders"
    
    # These should not yet be shown in UI, although they might be stored in DB
    # "email_when_new_friend_request",
    # "email_when_new_feedback_on_transaction",
    # "email_when_new_listing_from_friend"
  ] 
    
  serialize :preferences
  
  # Returns conversations for the "received" and "sent" actions
  def messages_that_are(action)
    conversations.joins(:participations).where("participations.last_#{action}_at IS NOT NULL").order("participations.last_#{action}_at DESC").uniq
  end
  
  def feedback_average
    ((received_testimonials.average(:grade) * 4 + 1) * 10).round / 10.0
  end
  
  # Create a new person to ASI and Kassi.
  def self.create(params, cookie, asi_welcome_mail = false)
    
    # Try to create the person to ASI
    person_hash = {:person => params.slice(:username, :password, :email, :consent), :welcome_email => asi_welcome_mail}
    response = PersonConnection.create_person(person_hash, cookie)

    # Pick id from the response (same id in kassi and ASI DBs)
    params[:id] = response["entry"]["id"]
    
    # Because ASI now associates the used cookie to a session for the newly created user
    # Change the KassiCookie to nil if it was used (because now it is no more an app-only cookie) 
    Session.update_kassi_cookie   if  (cookie == Session.kassi_cookie)    
    
    # Add name information for the person to ASI 
    params["given_name"] = params["given_name"].slice(0, 28)
    params["family_name"] = params["family_name"].slice(0, 28)
    Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])  
    PersonConnection.put_attributes(params.except(:username, :email, :password, :password2, :locale, :terms, :id, :test_group_number, :consent), params[:id], cookie)
    
    # Create locally with less attributes 
    super(params.except(:username, :email, "name", :terms, :consent))
  end 
  
  def set_default_preferences
    self.preferences = {}
    EMAIL_NOTIFICATION_TYPES.each { |t| self.preferences[t] = true }
    save
  end
  
  # Creates a record to local DB with given id
  # Should be used only with ids that exist also in ASI
  def self.add_to_kassi_db(id)
    person = Person.new({:id => id })
    if person.save
      return person
    else
      return nil
      logger.error { "Error storing person to Kassi DB with ID: #{id}" }
    end
  end


  # Using GUID string as primary key and id requires little fixing like this
  def initialize(params={})
    self.guid = params[:id] #store GUID to temporary attribute
    super(params)
  end
  
  def after_initialize
    #self.id may already be correct in this point so use ||=
    self.id ||= self.guid
  end
  
  def self.search(query)
    cookie = Session.kassi_cookie
    begin
      person_hash = PersonConnection.search(query, cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in ASI Database!
      return nil
    end  
    return person_hash
  end
  
  def self.search_by_phone_number(number)
    cookie = Session.kassi_cookie
    begin
      person_hash = PersonConnection.search_by_phone_number(number, cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in ASI Database!
      return nil
    end  
    return person_hash["entry"][0]
  end
  
  def self.username_available?(username, cookie=Session.kassi_cookie)
    resp = PersonConnection.availability({:username => username}, cookie)
    if resp["entry"] && resp["entry"][0]["username"] && resp["entry"][0]["username"] == "unavailable"
      return false
    else
      return true
    end
  end

  def self.email_available?(email, cookie=Session.kassi_cookie)
    resp = PersonConnection.availability({:email => email}, cookie)
    if resp["entry"] && resp["entry"][0]["email"] && resp["entry"][0]["email"] == "unavailable"
      return false
    else
      return true
    end
  end
  
  def username(cookie=nil)
    # No expire time, because username doesn't change (at least not yet)
    Rails.cache.fetch("person_username/#{self.id}") {username_from_person_hash(cookie)}  
  end
  
  def username_from_person_hash(cookie=nil)
    if new_record?
      return form_username ? form_username : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["username"]
  end
  
  def name_or_username(cookie=nil)
    # First check the person name cache (which is common to all users)
    # If not found use the person_hash cache (which is separate for each asker)
    
    Rails.cache.fetch("person_name/#{self.id}", :expires_in => PERSON_NAME_CACHE_EXPIRE_TIME) {name_or_username_from_person_hash(cookie)}
  end
      
  def name_or_username_from_person_hash(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    if person_hash["name"] && person_hash["name"]["unstructured"] && person_hash["name"]["unstructured"] =~ /\S/
      return person_hash["name"]["unstructured"]
    else
      return person_hash["username"]
    end
  end
  
  def name(cookie=nil)
    # We rather return the username than blank if no name is set
    return name_or_username(cookie)
  end
  
  def given_name_or_username(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    if person_hash["name"].nil? || person_hash["name"]["given_name"].blank?
      return person_hash["username"]
    end
    return person_hash["name"]["given_name"]
  end
  
  def given_name(cookie=nil)
    if new_record?
      return form_given_name ? form_given_name : ""
    end
    # We rather return the username than blank if no given name is set
    return Rails.cache.fetch("given_name/#{self.id}", :expires_in => PERSON_NAME_CACHE_EXPIRE_TIME) {given_name_or_username(cookie)}
    #given_name_or_username(cookie) 
  end
  
  def set_given_name(name, cookie)
    update_attributes({:name => {:given_name => name } }, cookie)
  end
  
  def family_name(cookie=nil)
    if new_record?
      return form_family_name ? form_family_name : ""
    end
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["name"].nil?
    return person_hash["name"]["family_name"]
  end
  
  def set_family_name(name, cookie)
    update_attributes({:name => {:family_name => name } }, cookie)
  end
  
  def street_address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["street_address"]
  end
  
  def set_street_address(street_address, cookie)
    update_attributes({:address => {:street_address => street_address } }, cookie)
  end
  
  def postal_code(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["postal_code"]
  end
  
  def set_postal_code(postal_code, cookie)
    update_attributes({:address => {:postal_code => postal_code } }, cookie)
  end
  
  def locality(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["locality"]
  end
  
  def set_locality(locality, cookie)
    update_attributes({:address => {:locality => locality } }, cookie)
  end
  
  def unstructured_address(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Not found!" if person_hash.nil?
    return "" if person_hash["address"].nil?
    return person_hash["address"]["unstructured"]
  end
  
  def phone_number(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["phone_number"]
  end
  
  def set_phone_number(number, cookie)
    update_attributes({:phone_number => number}, cookie)
  end
  
  def email(cookie=nil)
    if new_record?
      return form_email ? form_email : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["email"]
  end
  
  def set_email(email, cookie)
    update_attributes({:email => email}, cookie)
  end
  
  def password(cookie = nil)
    if new_record?
      return form_password ? form_password : ""
    end
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["password"]
  end
  
  def set_password(password, cookie)
    update_attributes({:password => password}, cookie)
  end
  
  def password2
    if new_record?
      return form_password2 ? form_password2 : ""
    end
  end
  
  def description(cookie=nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    
    return person_hash["description"]
  end
  
  def set_description(description, cookie)
    update_attributes({:description => description}, cookie)
  end
  
  # Returns friends of this person as an array of Person objects
  def friends(cookie)
    Person.find_kassi_users_by_ids(get_friend_ids(cookie))
  end
  
  # Returns ids of friends (in ASI) of this person
  def get_friend_ids(cookie)
    Person.get_person_ids(get_friends(cookie))
  end
  
  # Returns those people who are also kassi users
  def self.find_kassi_users_by_ids(ids)
    Person.find_by_sql("SELECT * FROM people WHERE id IN ('" + ids.join("', '") + "')")
  end
  
  def add_as_friend(friend_id, cookie)
    PersonConnection.add_as_friend(friend_id, self.id, cookie)
  end
  
  def remove_from_friends(friend_id, cookie)
    PersonConnection.remove_from_friends(friend_id, self.id, cookie)
  end
  
  def remove_pending_friend_request(friend_id, cookie)
    PersonConnection.remove_from_friends(friend_id, self.id, cookie)
  end
  
  # Retrieves friends of this person from ASI
  def get_friends(cookie)
    friend_hash = PersonConnection.get_friends(self.id, cookie)
    return friend_hash
  end
  
  def get_friend_requests(cookie)
    request_hash = PersonConnection.get_pending_friend_requests(self.id, cookie)
    return request_hash
  end
  
  def update_attributes(params, cookie=nil)
    if params[:preferences]
      super(params)
    else  
      #Handle name part parameters also if they are in hash root level
      Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])
      Person.remove_root_level_fields(params, "address", ["street_address", "postal_code", "locality"]) 
      if params["name"] || params[:name]
        # If name is going to be changed, expire name cache
        Rails.cache.delete("person_name/#{self.id}")
        Rails.cache.delete("given_name/#{self.id}")
      end
      PersonConnection.put_attributes(params.except("password2"), self.id, cookie)
    end
  end
  
  def update_avatar(file, cookie)
    path = file.path
    original_filename = file.original_filename
    new_path = path.gsub(/\/[^\/]+\Z/, "/#{original_filename}")
    
    logger.info "path #{path} original_filename #{original_filename} new_path #{new_path}"
    
    #rename the file to get a suffix and content type accepted by COS
    File.rename(path, new_path)
    
    file_to_post = File.new(new_path)
    
    logger.info "FILE TO POST #{file_to_post.path}"
    success = true
    begin 
      PersonConnection.update_avatar(file_to_post, self.id, cookie)
    rescue Exception => e
      logger.info "ASI error: #{e.message.to_s}"
      success = false
      begin
        File.delete(path)
      rescue
        #don't care if fails
      end
    end
    File.delete(new_path) if file_to_post || file_to_post.exists?
    return success
  end
  
  def get_person_hash(cookie=nil)
    cookie = Session.kassi_cookie if cookie.nil?
    
    begin
      person_hash = Person.cache_fetch(id,cookie)
    rescue RestClient::ResourceNotFound => e
      #Could not find person with that id in ASI Database!
      return nil
    end
    
    return person_hash["entry"]
  end
  
  def friend_status(cookie = nil)
    person_hash = get_person_hash(cookie)
    return "Person not found!" if person_hash.nil?
    return person_hash["connection"]
  end
  
  # Takes a person hash from ASI and extracts ids from it
  # into an array.
  def self.get_person_ids(person_hash)
    return nil if person_hash.nil?
    person_hash["entry"].collect { |person| person["id"] }
  end
  
  
  # Returns true if the person has admin rights in Kassi.
  def is_admin?
    is_admin == 1
  end
    
  # Starts following a listing
  def follow(listing)
    followed_listings << listing
  end
  
  # Unfollows a listing
  def unfollow(listing)
    followed_listings.delete(listing)
  end
  
  # Checks if this user is following the given listing
  def is_following?(listing)
    followed_listings.include?(listing)
  end
  
  # Updates the user following status based on the given status
  # for the given listing
  def update_follow_status(listing, status)
    unless id == listing.author.id
      if status
        follow(listing) unless is_following?(listing)
      else
        unfollow(listing) if is_following?(listing)
      end
    end
  end
  
  def create_listing(params)
    listings.create params
  end
  
  def read(conversation)
    conversation.participations.where(["person_id LIKE ?", self.id]).first.update_attribute(:is_read, true)
  end
  
  # Methods to simplify the cache access
  
  def self.cache_fetch(id,cookie)
    # FIXME: CACHING DISABLED DUE PROBLEMS AT ALPHA SERVER
    PersonConnection.get_person(id, cookie)  # A line to skip the cache temporarily
    #Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
  end
  
  def self.cache_write(person_hash,id,cookie)
    Rails.cache.write(cache_key(id,cookie), person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
  end
    
  def self.cache_delete(id,cookie)
    Rails.cache.delete(cache_key(id,cookie))
  end
  
  def give_badge(badge_name, host)
    unless has_badge?(badge_name)
      badge = Badge.create(:person_id => id, :name => badge_name)
      BadgeNotification.create(:badge_id => badge.id, :receiver_id => id)
      if preferences["email_about_new_badges"]
        PersonMailer.new_badge(badge, host).deliver
      end
    end
  end
  
  def has_badge?(badge)
    ! badges.find_by_name(badge).nil?
  end
  
  def mark_all_notifications_as_read
    Notification.update_all("is_read = 1", ["is_read = 0 AND receiver_id = ?", id])
  end
  
  def grade_amounts
    grade_amounts = []
    Testimonial::GRADES.each_with_index do |grade, index|
      grade_amounts[Testimonial::GRADES.size - 1 - index] = [grade[0], received_testimonials.where(:grade => grade[1][:db_value]).count, grade[1][:form_value]]
    end  
    return grade_amounts  
  end
  
  def can_give_feedback_on?(conversation)
    participation = Participation.find_by_person_id_and_conversation_id(id, conversation.id)
    participation.feedback_can_be_given?
  end
  
  def badges_visible_to?(person)
    if person
      self.eql?(person) ? true : [2,4].include?(person.test_group_number)
    else
      false
    end
  end
  
  def consent(community)
    community_memberships.find_by_community_id(community.id).consent
  end
  
  # Return the people who are admins of the given community
  def self.admins_of(community)
    joins(:community_memberships).where(["community_id = ? AND admin = 1", community.id])
  end
  
  private
  
  # This method constructs a key to be used in caching.
  # Important thing is that cache contains peoples profiles, but
  # the contents stored may be different, depending on who's asking.
  # Therefore the key contains person_id and a hash calculated from cookie.
  # (Cookie is different for each asker.)
  def self.cache_key(id,cookie)
    "person_hash.#{id}_asked_by.#{cookie.hash}"
  end
  
  def self.groups_cache_key(id,cookie)
    "person_groups_hash.#{id}_asked_by.#{cookie.hash}"
  end
  
  def self.remove_root_level_fields(params, field_type, fields)
    fields.each do |field|
      if params[field] && (params[field_type].nil? || params[field_type][field].nil?)
        params.update({field_type => Hash.new}) if params[field_type].nil?
        params[field_type].update({field => params[field]})
        params.delete(field)
      end
    end
  end
  
end
