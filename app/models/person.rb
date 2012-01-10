require 'json'
require 'rest_client'
require 'httpclient'



# This class represents a person (a user of Kassi).
# Some of the person data can be stored in Aalto Social Interface (ASI) server.
# if use_asi is set to true in config.yml some methods are loaded from asi_person.rb


class Person < ActiveRecord::Base

  include ErrorsHelper

  # Include devise module confirmable always. Others depend on if ASI is used or not
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :confirmable
    
  if not APP_CONFIG.use_asi
    # Include default devise modules. Others available are:
    # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
           
    if APP_CONFIG.crypto_helper_key.present?
      require Rails.root.join('lib', 'devise', 'encryptors', 'asi')
      devise :encryptable # to be able to use similar encrypt method as ASI
    end
  end
  
  # Setup accessible attributes for your model (the rest are protected)
  attr_accessible :username, :email, :password, :password2, :password_confirmation, 
                  :remember_me, :consent
      
  attr_accessor :guid, :password2, :form_username,
                :form_given_name, :form_family_name, :form_password, 
                :form_password2, :form_email, :consent, :show_real_name_setting_affected
  
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
  
  has_one :location, :conditions => ['location_type = ?', 'person'], :dependent => :destroy
  
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
  has_many :invitations, :foreign_key => "inviter_id", :dependent => :destroy
  
  has_and_belongs_to_many :followed_listings, :class_name => "Listing", :join_table => "listing_followers"
  
  EMAIL_NOTIFICATION_TYPES = [
    "email_about_new_messages",
    "email_about_new_comments_to_own_listing",
    "email_when_conversation_accepted",
    "email_when_conversation_rejected",
    "email_about_new_badges",
    "email_about_new_received_testimonials",
    "email_about_accept_reminders",
    "email_about_testimonial_reminders"
    
    # These should not yet be shown in UI, although they might be stored in DB
    # "email_when_new_friend_request",
    # "email_when_new_feedback_on_transaction",
    # "email_when_new_listing_from_friend"
  ] 
    
  serialize :preferences
  
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_length_of :phone_number, :maximum => 25, :allow_nil => true, :allow_blank => true
  validates_length_of :username, :within => 3..12
  validates_length_of :given_name, :within => 1..20, :allow_nil => true, :allow_blank => true
  validates_length_of :family_name, :within => 1..20, :allow_nil => true, :allow_blank => true
  validates_length_of :email, :maximum => 255

  validates_format_of :username,
                       :with => /^[A-Z0-9_]*$/i

  validates_format_of :password, :with => /^([\x20-\x7E])+$/,              
                       :allow_blank => true,
                       :allow_nil => true

  validates_format_of :email,
                       :with => /^[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
 
 
  # If ASI is in use the image settings below are not used as profile pictures are stored in ASI
  has_attached_file :image, :styles => { :medium => "200x350>", :thumb => "50x50#", :original => "600x800>" }
  #validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image,
                                      :content_type => ["image/jpeg", "image/png", "image/gif", 
                                        "image/pjpeg", "image/x-png"] #the two last types are sent by IE. 
 
  
  # This module contains the methods that are used to store used data on Kassi's database.
  # If ASI server is used, this module is not loaded, but AsiPerson module is loaded instead.
  module LocalPerson
      


    
         # 
         # PERSON_HASH_CACHE_EXPIRE_TIME = 15.minutes
         #  PERSON_NAME_CACHE_EXPIRE_TIME = 3.hours
         # 
         #  # Create a new person to ASI and Kassi.
         #  def Person.create(params, cookie, asi_welcome_mail = false)
         #    # Try to create the person to ASI
         #    person_hash = {:person => params.slice(:username, :password, :email, :consent), :welcome_email => asi_welcome_mail}
         #    response = PersonConnection.create_person(person_hash, cookie)
         # 
         #    # Pick id from the response (same id in kassi and ASI DBs)
         #    params[:id] = response["entry"]["id"]
         # 
         #    # Because ASI now associates the used cookie to a session for the newly created user
         #    # Change the KassiCookie to nil if it was used (because now it is no more an app-only cookie) 
         #    Session.update_kassi_cookie   if  (cookie == Session.kassi_cookie)    
         # 
         #    # Add name information for the person to ASI 
         #    params["given_name"] = params["given_name"].slice(0, 28)
         #    params["family_name"] = params["family_name"].slice(0, 28)
         #    Person.remove_root_level_fields(params, "name", ["given_name", "family_name"])  
         #    PersonConnection.put_attributes(params.except(:username, :email, :password, :password2, :locale, :terms, :id, :test_group_number, :consent, :confirmed_at, :show_real_name_to_other_users), params[:id], cookie)
         #    # Create locally with less attributes 
         #    super(params.except(:username, :email, "name", :terms, :consent))
         #  end
         # 
         #  # Using GUID string as primary key and id requires little fixing like this
         #  def initialize(params={})
         #    self.guid = params[:id] #store GUID to temporary attribute
         #    super(params)
         #  end
         # 
         #  def after_initialize
         #    #self.id may already be correct in this point so use ||=
         #    self.id ||= self.guid
         #  end
         # 
         #  # Creates a record to local DB with given id
         #  # Should be used only with ids that exist also in ASI
         #  def Person.add_to_kassi_db(id)
         #    person = Person.new({:id => id })
         #    if person.save
         #      return person
         #    else
         #      return nil
         #      logger.error { "Error storing person to Kassi DB with ID: #{id}" }
         #    end
         #  end
         # 
         #  def Person.search(query)
         #    cookie = Session.kassi_cookie
         #    begin
         #      person_hash = PersonConnection.search(query, cookie)
         #    rescue RestClient::ResourceNotFound => e
         #      #Could not find person with that id in ASI Database!
         #      return nil
         #    end  
         #    return person_hash
         #  end
         # 
         #  def Person.search_by_phone_number(number)
         #    cookie = Session.kassi_cookie
         #    begin
         #      person_hash = PersonConnection.search_by_phone_number(number, cookie)
         #    rescue RestClient::ResourceNotFound => e
         #      #Could not find person with that id in ASI Database!
         #      return nil
         #    end  
         #    return person_hash["entry"][0]
         #  end
         # 
         
         def Person.username_available?(username, cookie=nil)
           if Person.find_by_username(username).present?
             return false
           else
             return true
           end
         end

         def Person.email_available?(email, cookie=nil)
           if Person.find_by_email(email).present?
             return false
           else
             return true
           end
         end
         
         # 
         #  def username(cookie=nil)
         #    # No expire time, because username doesn't change (at least not yet)
         #    Rails.cache.fetch("person_username/#{self.id}") {username_from_person_hash(cookie)}  
         #  end
         # 
         #  def username_from_person_hash(cookie=nil)
         #    if new_record?
         #      return form_username ? form_username : ""
         #    end
         #    person_hash = get_person_hash(cookie)
         #    return "Person not found!" if person_hash.nil?
         #    return person_hash["username"]
         #  end
         # 
         

         def name_or_username(cookie=nil)
           if given_name.present? || family_name.present?
             return "#{given_name} #{family_name}"
           else
             return username
           end
         end
         
         def name(cookie=nil)
           # We rather return the username than blank if no name is set
           return username unless show_real_name_to_other_users
           return name_or_username(cookie)
         end
         
         def given_name_or_username(cookie=nil)
           if given_name.present? && show_real_name_to_other_users
             return given_name
           else
             return username
           end
         end
         
         # 
         #  def given_name(cookie=nil)
         #    if new_record?
         #      return form_given_name ? form_given_name : ""
         #    end
         # 
         #    return Rails.cache.fetch("person_given_name/#{self.id}", :expires_in => PERSON_NAME_CACHE_EXPIRE_TIME) {given_name_from_person_hash(cookie)} 
         #  end
         # 
         #  def given_name_from_person_hash(cookie)
         #    person_hash = get_person_hash(cookie)
         #    return "Not found!" if person_hash.nil?
         #    unless person_hash["name"].nil? || person_hash["name"]["given_name"].blank?
         #      return person_hash["name"]["given_name"]
         #    else
         #      return ""
         #    end
         #  end
         # 
         #  def set_given_name(name, cookie)
         #    update_attributes({:name => {:given_name => name } }, cookie)
         #  end
         # 
         #  def family_name(cookie=nil)
         #    if new_record?
         #      return form_family_name ? form_family_name : ""
         #    end
         #    person_hash = get_person_hash(cookie)
         #    return "Not found!" if person_hash.nil?
         #    return "" if person_hash["name"].nil?
         #    return person_hash["name"]["family_name"]
         #  end
         # 
         #  def set_family_name(name, cookie)
         #    update_attributes({:name => {:family_name => name } }, cookie)
         #  end
         # 
         
         def street_address(cookie=nil)
           if location
             return location.address
           else
             return nil
           end
         end
         
         # 
         #  def set_street_address(street_address, cookie)
         #    update_attributes({:address => {:street_address => street_address } }, cookie)
         #  end
         # 

         
         def email(cookie=nil)
           super()
         end
         

         # 
         #  def password(cookie = nil)
         #    if new_record?
         #      return form_password ? form_password : ""
         #    end
         #    person_hash = get_person_hash(cookie)
         #    return "Person not found!" if person_hash.nil?
         # 
         #    return person_hash["password"]
         #  end
         # 
         #  def set_password(password, cookie)
         #    update_attributes({:password => password}, cookie)
         #  end
         # 
         #  def description(cookie=nil)
         #    person_hash = get_person_hash(cookie)
         #    return "Person not found!" if person_hash.nil?
         # 
         #    return person_hash["description"]
         #  end
         # 
         #  def set_description(description, cookie)
         #    update_attributes({:description => description}, cookie)
         #  end
         # 
         #  # Returns friends of this person as an array of Person objects
         #  def friends(cookie)
         #    Person.find_kassi_users_by_ids(get_friend_ids(cookie))
         #  end
         # 
         #  # Returns ids of friends (in ASI) of this person
         #  def get_friend_ids(cookie)
         #    Person.get_person_ids(get_friends(cookie))
         #  end
         # 
         #  # Returns those people who are also kassi users
         #  def Person.find_kassi_users_by_ids(ids)
         #    Person.find_by_sql("SELECT * FROM people WHERE id IN ('" + ids.join("', '") + "')")
         #  end
         # 
         #  def add_as_friend(friend_id, cookie)
         #    PersonConnection.add_as_friend(friend_id, self.id, cookie)
         #  end
         # 
         #  def remove_from_friends(friend_id, cookie)
         #    PersonConnection.remove_from_friends(friend_id, self.id, cookie)
         #  end
         # 
         #  def remove_pending_friend_request(friend_id, cookie)
         #    PersonConnection.remove_from_friends(friend_id, self.id, cookie)
         #  end
         # 
         #  # Retrieves friends of this person from ASI
         #  def get_friends(cookie)
         #    friend_hash = PersonConnection.get_friends(self.id, cookie)
         #    return friend_hash
         #  end
         # 
         #  def get_friend_requests(cookie)
         #    request_hash = PersonConnection.get_pending_friend_requests(self.id, cookie)
         #    return request_hash
         #  end
         # 
         
         def update_attributes(params, cookie=nil)
           if params[:preferences]
             super(params)
           else  

             #Handle location information
             if self.location 
               #delete location always (it would be better to check for changes)
               self.location.delete
             end
             if params[:location]
               # Set the address part of the location to be similar to what the user wrote.
               # the google_address field will store the longer string for the exact position.
               params[:location][:address] = params[:street_address] if params[:street_address]

               self.location = Location.new(params[:location])
               params[:location].each {|key| params[:location].delete(key)}
               params.delete(:location)
             end

             self.show_real_name_to_other_users = (!params[:show_real_name_to_other_users] && params[:show_real_name_setting_affected]) ? false : true 
             save

             super(params.except("password2", "show_real_name_to_other_users", "show_real_name_setting_affected", "street_address"))    
           end
         end
         
         # 
         #  def get_person_hash(cookie=nil)
         #    cookie = Session.kassi_cookie if cookie.nil?
         # 
         #    begin
         #      person_hash = Person.cache_fetch(id,cookie)
         #    rescue RestClient::ResourceNotFound => e
         #      #Could not find person with that id in ASI Database!
         #      return nil
         #    end
         # 
         #    return person_hash["entry"]
         #  end
         # 
         #  def friend_status(cookie = nil)
         #    person_hash = get_person_hash(cookie)
         #    return "Person not found!" if person_hash.nil?
         #    return person_hash["connection"]
         #  end
         # 
         #  # Takes a person hash from ASI and extracts ids from it
         #  # into an array.
         #  def Person.get_person_ids(person_hash)
         #    return nil if person_hash.nil?
         #    person_hash["entry"].collect { |person| person["id"] }
         #  end
         # 
         #  # Methods to simplify the cache access
         #  def Person.cache_fetch(id,cookie)
         #    #PersonConnection.get_person(id, cookie)
         #    Rails.cache.fetch(cache_key(id,cookie), :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME) {PersonConnection.get_person(id, cookie)}
         #  end
         # 
         #  def Person.cache_write(person_hash,id,cookie)
         #    Rails.cache.write(cache_key(id,cookie), person_hash, :expires_in => PERSON_HASH_CACHE_EXPIRE_TIME)
         #  end
         # 
         #  def Person.cache_delete(id,cookie)
         #    Rails.cache.delete(cache_key(id,cookie))
         #  end
         #     
    
  end
  
  before_validation(:on => :create) do
      self.id = UUIDTools::UUID.timestamp_create().to_s
  end
  
  # Returns conversations for the "received" and "sent" actions
  def messages_that_are(action)
    conversations.joins(:participations).where("participations.last_#{action}_at IS NOT NULL").order("participations.last_#{action}_at DESC").uniq
  end
  
  def feedback_average
    ((received_testimonials.average(:grade) * 4 + 1) * 10).round / 10.0
  end
    
  def set_default_preferences
    self.preferences = {}
    EMAIL_NOTIFICATION_TYPES.each { |t| self.preferences[t] = true }
    self.preferences["email_about_weekly_events"] = true
    save
  end
  
  def password2
    if new_record?
      return form_password2 ? form_password2 : ""
    end
  end

  # Returns true if the person has global admin rights in Kassi.
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
  

  
  def give_badge(badge_name, host)
    unless has_badge?(badge_name)
      badge = Badge.create(:person_id => id, :name => badge_name)
      Notification.create(:notifiable_id => badge.id, :notifiable_type => "Badge", :receiver_id => id)
      if should_receive?("email_about_new_badges")
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
  
  def is_admin_of?(community)
    community_memberships.find_by_community_id(community.id).admin?
  end
  
  def has_admin_rights_in?(community)
    is_admin? || is_admin_of?(community)
  end
  
  def should_receive?(email_type)
    active && preferences[email_type]
  end
  
  def profile_info_empty?
    (phone_number.nil? || phone_number.blank?) && (description.nil? || description.blank?) && location.nil?
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
  
  # If ASI is in use, methods are loaded from AsiPerson, otherwise from LocalPersonMethods which is defined in this file
  if APP_CONFIG.use_asi
    include AsiPerson
  else
    include LocalPerson
  end
  
end

