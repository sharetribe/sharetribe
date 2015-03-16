# == Schema Information
#
# Table name: people
#
#  id                                 :string(22)       not null, primary key
#  created_at                         :datetime
#  updated_at                         :datetime
#  is_admin                           :integer          default(0)
#  locale                             :string(255)      default("fi")
#  preferences                        :text
#  active_days_count                  :integer          default(0)
#  last_page_load_date                :datetime
#  test_group_number                  :integer          default(1)
#  active                             :boolean          default(TRUE)
#  username                           :string(255)
#  email                              :string(255)
#  encrypted_password                 :string(255)      default(""), not null
#  reset_password_token               :string(255)
#  reset_password_sent_at             :datetime
#  remember_created_at                :datetime
#  sign_in_count                      :integer          default(0)
#  current_sign_in_at                 :datetime
#  last_sign_in_at                    :datetime
#  current_sign_in_ip                 :string(255)
#  last_sign_in_ip                    :string(255)
#  password_salt                      :string(255)
#  given_name                         :string(255)
#  family_name                        :string(255)
#  phone_number                       :string(255)
#  description                        :text
#  image_file_name                    :string(255)
#  image_content_type                 :string(255)
#  image_file_size                    :integer
#  image_updated_at                   :datetime
#  facebook_id                        :string(255)
#  authentication_token               :string(255)
#  community_updates_last_sent_at     :datetime
#  min_days_between_community_updates :integer          default(1)
#  is_organization                    :boolean
#  organization_name                  :string(255)
#  deleted                            :boolean          default(FALSE)
#
# Indexes
#
#  index_people_on_email                 (email) UNIQUE
#  index_people_on_facebook_id           (facebook_id) UNIQUE
#  index_people_on_id                    (id)
#  index_people_on_reset_password_token  (reset_password_token) UNIQUE
#  index_people_on_username              (username) UNIQUE
#

require 'json'
require 'rest_client'
require "open-uri"
require File.expand_path('../../../lib/np_guid/uuid22', __FILE__)

# This class represents a person (a user of Sharetribe).

class Person < ActiveRecord::Base

  include ErrorsHelper
  include ApplicationHelper

  self.primary_key = "id"

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :token_authenticatable

  if APP_CONFIG.use_asi_encryptor
    require Rails.root.join('lib', 'devise', 'encryptors', 'asi')
    devise :encryptable # to be able to use similar encrypt method as ASI
  end

  # Setup accessible attributes for your model (the rest are protected)
  attr_accessible :username, :password, :password2, :password_confirmation,
                  :remember_me, :consent, :login

  attr_accessor :guid, :password2, :form_login,
                :form_given_name, :form_family_name, :form_password,
                :form_password2, :form_email, :consent,
                :input_again, :community_category, :send_notifications

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  attr_protected :is_admin

  has_many :listings, :dependent => :destroy, :foreign_key => "author_id", :conditions => { :deleted => 0 }
  has_many :emails, :dependent => :destroy, :inverse_of => :person

  has_one :location, :conditions => ['location_type = ?', 'person'], :dependent => :destroy
  has_one :braintree_account, :dependent => :destroy
  has_one :checkout_account, dependent: :destroy

  has_many :participations, :dependent => :destroy
  has_many :conversations, :through => :participations, :dependent => :destroy
  has_many :authored_testimonials, :class_name => "Testimonial", :foreign_key => "author_id", :dependent => :destroy
  has_many :received_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :order => "id DESC", :dependent => :destroy
  has_many :received_positive_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :conditions => "grade IN (0.5,0.75,1)", :order => "id DESC"
  has_many :received_negative_testimonials, :class_name => "Testimonial", :foreign_key => "receiver_id", :conditions => "grade IN (0.0,0.25)", :order => "id DESC"
  has_many :messages, :foreign_key => "sender_id"
  has_many :authored_comments, :class_name => "Comment", :foreign_key => "author_id", :dependent => :destroy
  has_many :community_memberships, :dependent => :destroy
  has_many :communities, :through => :community_memberships, :conditions => ['status = ?', 'accepted']
  has_many :invitations, :foreign_key => "inviter_id", :dependent => :destroy
  has_many :auth_tokens, :dependent => :destroy
  has_many :follower_relationships
  has_many :followers, :through => :follower_relationships, :foreign_key => "person_id"
  has_many :inverse_follower_relationships, :class_name => "FollowerRelationship", :foreign_key => "follower_id"
  has_many :followed_people, :through => :inverse_follower_relationships, :source => "person"

  has_and_belongs_to_many :followed_listings, :class_name => "Listing", :join_table => "listing_followers"

  def to_param
    username
  end

  def self.find(username)
    super(self.find_by_username(username).try(:id) || username)
  end

  DEFAULT_TIME_FOR_COMMUNITY_UPDATES = 7.days

  # These are the email notifications, excluding newsletters settings
  EMAIL_NOTIFICATION_TYPES = [
    "email_about_new_messages",
    "email_about_new_comments_to_own_listing",
    "email_when_conversation_accepted",
    "email_when_conversation_rejected",
    "email_about_new_received_testimonials",
    "email_about_accept_reminders",
    "email_about_confirm_reminders",
    "email_about_testimonial_reminders",
    "email_about_completed_transactions",
    "email_about_new_payments",
    "email_about_payment_reminders",
    "email_about_new_listings_by_followed_people"

    # These should not yet be shown in UI, although they might be stored in DB
    # "email_when_new_friend_request",
    # "email_when_new_feedback_on_transaction",
    # "email_when_new_listing_from_friend"
  ]
  EMAIL_NEWSLETTER_TYPES = [
    "email_from_admins"
  ]

  PERSONAL_EMAIL_ENDINGS = ["gmail.com", "hotmail.com", "yahoo.com"]

  serialize :preferences

#  validates_uniqueness_of :username
  validates_length_of :phone_number, :maximum => 25, :allow_nil => true, :allow_blank => true
  validates_length_of :username, :within => 3..20
  validates_length_of :given_name, :within => 1..255, :allow_nil => true, :allow_blank => true
  validates_length_of :family_name, :within => 1..255, :allow_nil => true, :allow_blank => true

  validates_format_of :username,
                       :with => /\A[A-Z0-9_]*\z/i

  USERNAME_BLACKLIST = YAML.load_file("#{Rails.root}/config/username_blacklist.yml")

  validates :username, :exclusion => USERNAME_BLACKLIST
  validate :community_email_type_is_correct

  has_attached_file :image, :styles => {
                      :medium => "288x288#",
                      :small => "108x108#",
                      :thumb => "48x48#",
                      :original => "600x800>"},
                    :default_url => ActionController::Base.helpers.asset_path("/assets/profile_image/:style/missing.png", :digest => true)

  #validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 9.megabytes
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/gif",
                                      "image/pjpeg", "image/x-png"] #the two last types are sent by IE.

  before_validation(:on => :create) do
    self.id = UUID.timestamp_create.to_s22
    set_default_preferences unless self.preferences
  end

  # Creates a new email
  def email_attributes=(attributes)
    emails.build(attributes)
  end

  def set_emails_that_receive_notifications(email_ids)
    if email_ids
      emails.each do |email|
        email.update_attribute(:send_notifications, email_ids.include?(email.id.to_s))
      end
    end
  end

  # Override Devise's authentication finder method to allow log in with username OR email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)

      matched = where(conditions).where(["lower(username) = :value", { :value => login.downcase }]).first

      if matched
        return matched
      else
        e = Email.find_by_address(login.downcase)
        return e.person if e
      end
    else
      where(conditions).first
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

  def last_community_updates_at
    community_updates_last_sent_at || DEFAULT_TIME_FOR_COMMUNITY_UPDATES.ago
  end

  def self.username_blacklist
    USERNAME_BLACKLIST
  end

  def self.username_available?(username)
     !Person.find_by_username(username).present? && !username.in?(USERNAME_BLACKLIST)
   end

  # Deprecated: This is view logic (how to display name) and thus should not be in model layer
  # Consider using PersonViewUtils
  def name_or_username(community_or_display_type=nil)
    if community_or_display_type.present? && community_or_display_type.class == Community
      display_type = community_or_display_type.name_display_type
    else
      display_type = community_or_display_type
    end
    if is_organization
      return organization_name
    elsif given_name.present?
      if display_type
        case display_type
        when "first_name_with_initial"
          return first_name_with_initial
        when "first_name_only"
          return given_name
        else
          return full_name
        end
      else
        return first_name_with_initial
      end
    else
      return username
    end
  end

  # Deprecated: This is view logic (how to display name) and thus should not be in model layer
  # Consider using PersonViewUtils
  def full_name
    "#{given_name} #{family_name}"
  end

  # Deprecated: This is view logic (how to display name) and thus should not be in model layer
  # Consider using PersonViewUtils
  def first_name_with_initial
    if family_name
      initial = family_name[0,1]
    else
      initial = ""
    end
    "#{given_name} #{initial}"
  end

  # Deprecated: This is view logic (how to display name) and thus should not be in model layer
  # Consider using PersonViewUtils
  def name(community_or_display_type=nil)
    return name_or_username(community_or_display_type)
  end

  # Deprecated: This is view logic (how to display name) and thus should not be in model layer
  # Consider using PersonViewUtils
  def given_name_or_username
    if is_organization
      # Quick and somewhat dirty solution. `given_name_or_username`
      # is quite explicit method name and thus it should return the
      # given name or username. Maybe this should be cleaned in the future.
      return organization_name
    elsif given_name.present?
      return given_name
    else
      return username
    end
  end

  def set_given_name(name)
    update_attributes({:given_name => name })
  end

  def street_address
    if location
      return location.address
    else
      return nil
    end
  end

  def update_attributes(params)
    if params[:preferences]
      super(params)
    else

      #Handle location information
      if params[:location]
        if self.location && self.location.address != params[:street_address]
          #delete location and create a new one
          self.location.delete
        end

        # Set the address part of the location to be similar to what the user wrote.
        # the google_address field will store the longer string for the exact position.
        params[:location][:address] = params[:street_address] if params[:street_address]

        self.location = Location.new(params[:location])
        params[:location].each {|key| params[:location].delete(key)}
        params.delete(:location)
      end

      save
      super(params.except("password2", "street_address"))
    end
  end

  def picture_from_url(url)
    self.image = open(url)
    self.save
  end

  def store_picture_from_facebook()
    if self.facebook_id
      resp = RestClient.get("http://graph.facebook.com/#{self.facebook_id}/picture?type=large&redirect=false")
      url = JSON.parse(resp)["data"]["url"]
      self.picture_from_url(url)
    end
  end

  def offers
    listings.offers
  end

  def requests
    listings.requests
  end

  def feedback_average
    ((received_testimonials.average(:grade) * 4 + 1) * 10).round / 10.0
  end

  # The percentage of received testimonials with positive grades
  # (grades between 3 and 5 are positive, 1 and 2 are negative)
  def feedback_positive_percentage
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
    EMAIL_NEWSLETTER_TYPES.each { |t| self.preferences[t] = true }
    save
  end

  def password2
    if new_record?
      return form_password2 ? form_password2 : ""
    end
  end

  def can_delete_email(email)
    EmailService.can_delete_email(self.emails, email, self.communities.collect(&:allowed_emails))[:result]
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

  def read(conversation)
    conversation.participations.where(["person_id LIKE ?", self.id]).first.update_attribute(:is_read, true)
  end

  def grade_amounts
    grade_amounts = []
    Testimonial::GRADES.each_with_index do |grade, index|
      grade_amounts[Testimonial::GRADES.size - 1 - index] = [grade[0], received_testimonials.where(:grade => grade[1][:db_value]).count, grade[1][:form_value]]
    end
    return grade_amounts
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
    confirmed_email = !confirmed_notification_emails.empty?
    if email_type == "community_updates"
      # this is handled outside prefenrences so answer separately
      return active && confirmed_email && min_days_between_community_updates < 100000
    end
    active && confirmed_email && preferences && preferences[email_type]
  end

  def profile_info_empty?
    (phone_number.nil? || phone_number.blank?) && (description.nil? || description.blank?) && location.nil?
  end

  def member_of?(community)
    community.members.include?(self)
  end

  def can_post_listings_at?(community)
    self.community_memberships.where(:community_id => community.id).first.can_post_listings
    #CommunityMembership.find_by_person_id_and_community_id(id, community.id).can_post_listings
  end

  def banned_at?(community)
    memberships = self.community_memberships.find_by_community_id(community.id)
    !memberships.nil? && memberships.banned?
  end

  def has_email?(address)
    Email.find_by_address_and_person_id(address, self.id).present?
  end

  def confirmed_notification_emails
    emails.select do |email|
      email.send_notifications && email.confirmed_at.present?
    end
  end

  def confirmed_notification_email_addresses
    self.confirmed_notification_emails.collect(&:address)
  end

  # Notice: If no confirmed notification emails is found, this
  # method returns the first confirmed emails
  def confirmed_notification_emails_to
    send_message_to = EmailService.emails_to_send_message(emails)
    EmailService.emails_to_smtp_addresses(send_message_to)
  end

  # Notice: If no confirmed notification emails is found, this
  # method returns the first confirmed emails
  def confirmed_notification_email_to
    send_message_to = EmailService.emails_to_send_message(emails).first

    Maybe(send_message_to).map { |email|
      EmailService.emails_to_smtp_addresses([email])
    }.or_else(nil)
  end

  # Returns true if the address given as a parameter is confirmed
  def has_confirmed_email?(address)
    email = Email.find_by_address_and_person_id(address, self.id)
    email.present? && email.confirmed_at.present?
  end

  def has_valid_email_for_community?(community)
    community.can_accept_user_based_on_email?(self)
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
    email = Email.find_by_address(*args)
    if email
      email.person
    end
  end

  def reset_password_token_if_needed
    # Using methods from Devise
    generate_reset_password_token! if should_generate_reset_token?
  end

  # If image_file_name is null, it means the user
  # does not have a profile picture.
  def has_profile_picture?
    image_file_name.present?
  end

  def new_email_auth_token
    t = AuthToken.create(:person => self, :expires_at => 1.week.from_now, :token_type => "unsubscribe")
    return t.token
  end

  # Tell Devise that email is not required
  def email_required?
    false
  end

  # Tell Devise that email is not required
  def email_changed?
    false
  end

  # A person inherits some default settings from the community in which she is joining
  def inherit_settings_from(current_community)
    # Mark as organization user if signed up through market place which is only for orgs
    self.is_organization = current_community.only_organizations
    self.min_days_between_community_updates = current_community.default_min_days_between_community_updates
  end

  # Merge this person with the data from the person given as parameter
  # This person is saved and THE PERSON GIVEN IN PARAMETER IS DESTROYED
  # This should be called only from console, as it requires command line choises
  # for choosing from duplicate information
  def merge(source_person)

    print_mergeable_data(self, source_person)

    begin
      # Merge data in people table
      fields_to_check = %w(username given_name family_name phone_number description facebook_id authentication_token)
      fields_to_check.each do |attr|
        begin
          original_attr_value = self.try(attr)
          new_attr_value = get_existing_value_or_ask(attr, self, source_person )

          # if choosing unique field from source_person, need to change that first to be able to use same string for self
          if new_attr_value.present? && new_attr_value == source_person.try(attr)
            source_person.update_attribute(attr, "merged_#{source_person.try(attr)}")
          end

          self.update_attribute(attr, new_attr_value)

        rescue ActiveRecord::RecordNotUnique => e
          puts "Can' set #{attr} to #{self.try(attr)}, not unique. #{e.message}"
          self.update_attribute(attr, original_attr_value)
        end
        puts "Updated #{attr} => #{self.try(attr)}"
      end

      selected_image = get_existing_value_or_ask("image_file_name", self, source_person )
      if selected_image != self.image_file_name
        self.image = source_person.image
      end

      self.save!

      # Move other assets to be owned by the this person
      source_person.listings.each  { |asset| asset.author = self ; asset.save( :validate => false ) }
      source_person.emails.each { |asset| asset.person = self ; asset.save(:validate => false) }
      source_person.participations.each { |asset| asset.person = self ; asset.save(:validate => false) }
      source_person.authored_testimonials.each  { |asset| asset.author = self ; asset.save(:validate => false) }
      source_person.received_testimonials.each  { |asset| asset.receiver = self ; asset.save(:validate => false) }
      source_person.messages.each  { |asset| asset.sender = self ; asset.save(:validate => false) }
      source_person.authored_comments.each  { |asset| asset.author = self ; asset.save(:validate => false) }
      source_person.community_memberships.each  { |asset| asset.person = self ; asset.save(:validate => false)}
      source_person.invitations.each { |asset| asset.inviter = self ; asset.save(:validate => false) }
      source_person.invitations.each { |asset| asset.inviter = self ; asset.save(:validate => false) }
      source_person.followed_listings.each { |asset| self.followed_listings << asset}
      Feedback.find_all_by_author_id(source_person.id).each { |asset| asset.author = self ; asset.save(:validate => false) }

      # Location. Pick from source_person only if primary account doesn't have
      if self.location.nil? && source_person.location.present?
        loc = source_person.location
        loc.person = self
        loc.save
      end

      # Finally delete source_person
      source_person = Person.find(source_person.id) # Find again from DB to refres active record relations

      print_mergeable_data(self, source_person)

      puts "merged person with id #{source_person.id} to #{self.id} and deleting the source person."
      if (
          source_person.listings.count == 0 &&
          source_person.authored_comments.count == 0 &&
          source_person.authored_testimonials.count == 0 &&
          source_person.received_testimonials.count == 0 &&
          source_person.community_memberships.count == 0 &&
          source_person.participations.count == 0 &&
          source_person.messages.count == 0
          )

        source_person.destroy
      else
        puts "Did not destroy #{source_person.id} because some assets were not transferred succesfully"
      end

    rescue
      puts "Aborted migrating this person. Some fields may have been changed."
    end
  end

  def should_receive_community_updates_now?
    return false unless should_receive?("community_updates")
    # return whether or not enought time has passed. The - 45.minutes is because the sending takes some time so we want
    # 1 day limit to match even if there's 23.55 minutes passed since last sending.
    return true if community_updates_last_sent_at.nil?
    return community_updates_last_sent_at + min_days_between_community_updates.days - 45.minutes < Time.now
  end

  # Return true if this user should use a payment
  # system in this transaction
  def should_pay?(conversation, community)
    conversation.requires_payment?(community) && conversation.status.eql?("accepted") && id.eql?(conversation.buyer.id)
  end

  def pending_email_confirmation_to_join?(community)
    membership = community_memberships.where(:community_id => community.id).first
    if membership
      return (membership.status == "pending_email_confirmation")
    else
      return false
    end
  end

  # Returns and email that is pending confirmation
  # If community is given as parameter, in case of many pending
  # emails the one required by the community is returned
  def latest_pending_email_address(community=nil)
    pending_emails = []
    Email.where(:person_id => id, :confirmed_at => nil).all.each { |e| pending_emails << e.address }

    allowed_emails = if community && community.allowed_emails
      pending_emails.select do |e|
        community.email_allowed?(e)
      end
    else
      pending_emails
    end

    allowed_emails.last
  end

  # FIXME!
  # This should be removed: After the recent changes, everyone can create paid listing
  # even without payment details
  def can_create_paid_listings_at?(community)
    true
  end

  def follows?(person)
    followed_people_by_id.include?(person.id)
  end

  def followed_people_by_id
    @followed_people_by_id ||= followed_people.group_by(&:id)
  end

  def self.members_of(community)
    joins(:communities).where("communities.id" => community.id)
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

  def get_existing_value_or_ask(attribute, p1, p2)
    if p2.try(attribute)
      if p1.try(attribute)
        # both have this attribute
        if p1.try(attribute) != p2.try(attribute)
          return ask_user_for_merge_options(attribute, p1.try(attribute), p2.try(attribute) )
        else
          # same value, return p1
          return  p1.try(attribute)
        end

      else
        #if p1 didin't have, use from p2
        return p2.try(attribute)
      end

    else
      #if p2 didin't have, use from p1 anyway
      return p1.try(attribute)
    end

  end

  def ask_user_for_merge_options(attribute_name, option1, option2)
    return option1 if attribute_name == "email" && option2.match(/^merge_/)
    option = 0
    while (option < 1 || option > 3) do
      puts "Which one of these should be used for #{attribute_name}"
      puts "1. #{option1}"
      puts "2. #{option2}"
      puts "3. Abort merge (changed fields stay changed)"
      option = gets.chomp.to_i
    end
    if option == 1
      return option1
    elsif option == 2
      return option2
    elsif option == 3
      throw Execption.new("abort merge")
    else
      puts "error in merge script, selection exited with value other than 1 or 2."
    end
  end

  def print_mergeable_data(p1, p2)
    puts "Merge comparison:"
    puts "ID:\t#{p1.id}\t#{p2.id}"
    puts "seen_at:\t#{p1.current_sign_in_at}\t#{p2.current_sign_in_at}"
    puts "username:\t#{p1.username}\t#{p2.username}"
    puts "emails:\t#{p1.emails.join(",")}\t#{p2.emails.join(",")}"
    puts "given_name:\t#{p1.given_name}\t#{p2.given_name}"
    puts "family_name:\t#{p1.family_name}\t#{p2.family_name}"
    puts "listings:\t#{p1.listings.count}\t#{p2.listings.count}"
    puts "comments:\t#{p1.authored_comments.count}\t#{p2.authored_comments.count}"
    puts "auth_testim:\t#{p1.authored_testimonials.count}\t#{p2.authored_testimonials.count}"
    puts "rec_testim:\t#{p1.received_testimonials.count}\t#{p2.received_testimonials.count}"
    puts "comm_memb:\t#{p1.community_memberships.count}\t#{p2.community_memberships.count}"
    puts "participations:\t#{p1.participations.count}\t#{p2.participations.count}"
    puts "messages:\t#{p1.messages.count}\t#{p2.messages.count}"
  end
end
