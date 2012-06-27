require 'json'
require 'rest_client'
require 'httpclient'
require 'uuid22'
require "open-uri"

# This class represents a person (a user of Sharetribe).
# Some of the person data can be stored in Aalto Social Interface (ASI) server.
# if use_asi is set to true in config.yml some methods are loaded from asi_person.rb


class Person < ActiveRecord::Base

  include ErrorsHelper
  include ApplicationHelper

  # Include devise module confirmable always. Others depend on if ASI is used or not
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :confirmable
    
  if not ApplicationHelper::use_asi?
    # Include default devise modules. Others available are:
    # :lockable, :timeoutable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, 
           :validatable, :omniauthable, :token_authenticatable
           
    if APP_CONFIG.use_asi_encryptor
      require Rails.root.join('lib', 'devise', 'encryptors', 'asi')
      devise :encryptable # to be able to use similar encrypt method as ASI
    end
  end
  
  # Setup accessible attributes for your model (the rest are protected)
  attr_accessible :username, :email, :password, :password2, :password_confirmation, 
                  :remember_me, :consent
      
  attr_accessor :guid, :password2, :form_username,
                :form_given_name, :form_family_name, :form_password, 
                :form_password2, :form_email, :consent, :show_real_name_setting_affected,
                :email_confirmation, :community_category

  
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
  has_many :emails, :dependent => :destroy
  
  has_one :location, :conditions => ['location_type = ?', 'person'], :dependent => :destroy
  
  has_many :participations, :dependent => :destroy 
  has_many :conversations, :through => :participations
  has_many :authored_testimonials, :class_name => "Testimonial", :foreign_key => "author_id"
  has_many :received_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :order => "id DESC"
  has_many :received_positive_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :conditions => "grade IN (0.5,0.75,1)", :order => "id DESC"
  has_many :received_negative_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :conditions => "grade IN (0.0,0.25)", :order => "id DESC"
  has_many :messages, :foreign_key => "sender_id"
  has_many :badges, :dependent => :destroy 
  has_many :notifications, :foreign_key => "receiver_id", :order => "id DESC"
  has_many :authored_comments, :class_name => "Comment", :foreign_key => "author_id", :dependent => :destroy
  has_many :community_memberships, :dependent => :destroy 
  has_many :communities, :through => :community_memberships
  has_many :invitations, :foreign_key => "inviter_id", :dependent => :destroy
  has_many :poll_answers, :class_name => "PollAnswer", :foreign_key => "answerer_id", :dependent => :destroy
  has_many :answered_polls, :through => :poll_answers, :source => :poll
  
  has_and_belongs_to_many :followed_listings, :class_name => "Listing", :join_table => "listing_followers"
  has_and_belongs_to_many :hobbies, :join_table => 'person_hobbies'

  
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
  
  PERSONAL_EMAIL_ENDINGS = ["gmail.com", "hotmail.com", "yahoo.com"]
    
  serialize :preferences
  

  if not ApplicationHelper::use_asi?
    validates_uniqueness_of :username
    validates_uniqueness_of :email
    validates_length_of :phone_number, :maximum => 25, :allow_nil => true, :allow_blank => true
    validates_length_of :username, :within => 3..20
    validates_length_of :given_name, :within => 1..30, :allow_nil => true, :allow_blank => true
    validates_length_of :family_name, :within => 1..30, :allow_nil => true, :allow_blank => true
    validates_length_of :email, :maximum => 255


    validates_format_of :username,
                         :with => /^[A-Z0-9_]*$/i

    validates_format_of :password, :with => /^([\x20-\x7E])+$/,              
                         :allow_blank => true,
                         :allow_nil => true

    validates_format_of :email,
                         :with => /^[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
 
    validate :community_email_type_is_correct
 
    # If ASI is in use the image settings below are not used as profile pictures are stored in ASI
    has_attached_file :image, :styles => { :medium => "200x350>", :thumb => "50x50#", :original => "600x800>" }
    #validates_attachment_presence :image
    validates_attachment_size :image, :less_than => 5.megabytes
    validates_attachment_content_type :image,
                                      :content_type => ["image/jpeg", "image/png", "image/gif", 
                                        "image/pjpeg", "image/x-png"] #the two last types are sent by IE. 
 
    before_validation(:on => :create) do
      self.id = UUID.timestamp_create.to_s22
    end
 
  else # this is only needed if ASI is in use
  
    before_validation(:on => :create) do
      #self.id may already be correct in this point so use ||=
      self.id ||= self.guid
    end
    
  end
  
  def community_email_type_is_correct
    if ["university", "community"].include? community_category
      email_ending = email.split('@')[1]
      if PERSONAL_EMAIL_ENDINGS.include? email_ending
        errors.add(:email, "This looks like a non-organization email address. Remember to use the email of your organization.")
      end
    end
  end
  
  
  # # ***********************************************************************************
  # This module contains the methods that are used to store used data on Sharetribe's database.
  # If ASI server is used, this module is not loaded, but AsiPerson module is loaded instead.
  module LocalPerson
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods  
      
      def asi_methods_loaded?
        return false
      end

      def username_available?(username, cookie=nil)
         if Person.find_by_username(username).present?
           return false
         else
           return true
         end
       end

       def email_available?(email, cookie=nil)
         if Person.find_by_email(email).present? || Email.find_by_address(email).present?
           return false
         else
           return true
         end
       end
    
    end #end the module ClassMethods

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

    def set_given_name(name, cookie=nil)
      update_attributes({:given_name => name })
    end

    def street_address(cookie=nil)
      if location
        return location.address
      else
        return nil
      end
    end

    def email(cookie=nil)
      super()
    end

    def set_email(email, cookie=nil)
      update_attributes({:email => email})
    end

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

        if params[:hobbies]
          # compile a new hobbies list
          temp_hobbies = []
          params[:hobbies].each do |field, value|
            value.strip!

            if field == 'other'
              if value != ''
                # comma-separated, 'non-official', other hobbies
                value.split(',').each do |v|
                  temp_hobbies << Hobby.find_or_create_by_name(:name => v.strip.titleize, :official => false)
                end
              end
            else
              # 'official' hobby
              temp_hobbies << Hobby.find_by_id(value)
            end
          end

          # update the actual hobbies list from the new list
          self.hobbies.each do |h|
            # if it's not in the new list, delete it
            if not temp_hobbies.include? h
              self.hobbies.delete h
            end
          end
          temp_hobbies.each do |h|
            # if it's not in the list, add it
            if not self.hobbies.include? h
              self.hobbies << h
            end
          end

          # [TODO: update hobbies_status]
        end

        super(params.except("password2", "show_real_name_to_other_users", "show_real_name_setting_affected", "street_address", "hobbies"))    
      end
    end
    
    def picture_from_url(url)
      self.image = open(url)
      self.save
    end
    
    def store_picture_from_facebook()
      if self.facebook_id
        self.picture_from_url "http://graph.facebook.com/#{self.facebook_id}/picture?type=large"
      end
    end
  end
  
  
  
  
  
  # *************************************************************************************
  # Below start the methods that are used for Person class not depending on if ASI is in use or not.
  
  
  # Returns conversations for the "received" and "sent" actions
  def messages_that_are(action)
    conversations.joins(:participations).where("participations.last_#{action}_at IS NOT NULL").order("participations.last_#{action}_at DESC").uniq
  end
  
  def feedback_average
    ((received_testimonials.average(:grade) * 4 + 1) * 10).round / 10.0
  end
  
  # The percentage of received testimonials with positive grades
  # (grades between 3 and 5 are positive, 1 and 2 are negative)
  def feedback_positive_percentage
    logger.info "Here we are"
    if received_positive_testimonials.size > 0
      if received_negative_testimonials.size > 0
        (received_positive_testimonials.size.to_f/received_testimonials.size.to_f*100).round
      else
        return 100
      end
    elsif received_negative_testimonials.size > 0
      return 0
    end  
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

  # Returns true if the person has global admin rights in Sharetribe.
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
  
  # This methods can be used to control whether certain badges
  # are shown to this person. Currently everybody sees all badges.
  def badges_visible_to?(person)
    return true
    # if person
    #   self.eql?(person) ? true : [2,4].include?(person.test_group_number)
    # else
    #   false
    # end
  end
  
  def consent(community)
    community_memberships.find_by_community_id(community.id).consent
  end
  
  def is_admin_of?(community)
    community_membership = community_memberships.find_by_community_id(community.id)
    community_membership && community_membership.admin?
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
  
  def member_of?(community)
    community.members.include?(self)
  end
  
  def has_email?(address)
    self.email == address || Email.find_by_address_and_person_id(address, self.id).present?
  end
  
  def has_confirmed_email?(address)
    additional_email = Email.find_by_address(address)
    (self.email.eql?(address) && self.confirmed_at) || (additional_email && additional_email.confirmed_at?)
  end
  
  def has_valid_email_for_community?(community)
    allowed = false
    
    #check primary email
    allowed = true if community.email_allowed?(self.email)
    
    #check additional confirmed emails
    self.emails.select{|e| e.confirmed_at.present?}.each do |e|
      allowed = true if community.email_allowed?(e.address)
    end
    
    return allowed
  end
  
  def self.find_for_facebook_oauth(facebook_data, logged_in_user=nil)
    data = facebook_data.extra.raw_info
    
    # find if already made facebook connection
    if user = self.find_by_facebook_id(data.id)
      user
    elsif user = logged_in_user || self.find_by_email(data.email)
      # make connection automatically based on email
      user.update_attribute(:facebook_id, data.id)
      if user.image_file_size.nil?
        user.store_picture_from_facebook
      end
      user 
    else 
      nil
    end
  end
  
  # Override the default finder to find also based on additional emails
  def self.find_by_email(*args)
    person = super(*args)
    
    if person.nil?
      # look for additional emails
      email = Email.find_by_address(*args)
      if email
        person = email.person
      end
    end
    
    return person
  end
  
  # returns the same if its available, otherwise "same1", "same2" etc.
  def self.available_username_based_on(initial_name)
    current_name = initial_name
    i = 1
    while self.find_by_username(current_name) do
      current_name = "#{initial_name}#{i}"
      i += 1
    end
    return current_name
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
  
  def self.email_all_users(subject, mail_content, default_locale="en", verbose=false, emails_to_skip=[])
    puts "Sending mail to every #{Person.count} users in the service" if verbose
    PersonMailer.deliver_open_content_messages(Person.all, subject, mail_content, default_locale, verbose, emails_to_skip)
  end
  
  # If ASI is in use, methods are loaded from AsiPerson, otherwise from LocalPersonMethods which is defined in this file
  if ApplicationHelper.use_asi?
    include AsiPerson
  else
    include LocalPerson
  end
  
end

