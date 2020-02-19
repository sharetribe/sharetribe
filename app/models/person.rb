# == Schema Information
#
# Table name: people
#
#  id                                 :string(22)       not null, primary key
#  uuid                               :binary(16)       not null
#  community_id                       :integer          not null
#  created_at                         :datetime
#  updated_at                         :datetime
#  is_admin                           :integer          default(0)
#  locale                             :string(255)      default("fi")
#  preferences                        :text(65535)
#  active_days_count                  :integer          default(0)
#  last_page_load_date                :datetime
#  test_group_number                  :integer          default(1)
#  username                           :string(255)      not null
#  email                              :string(255)
#  encrypted_password                 :string(255)      default(""), not null
#  legacy_encrypted_password          :string(255)
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
#  display_name                       :string(255)
#  phone_number                       :string(255)
#  description                        :text(65535)
#  image_file_name                    :string(255)
#  image_content_type                 :string(255)
#  image_file_size                    :integer
#  image_updated_at                   :datetime
#  image_processing                   :boolean
#  facebook_id                        :string(255)
#  authentication_token               :string(255)
#  community_updates_last_sent_at     :datetime
#  min_days_between_community_updates :integer          default(1)
#  deleted                            :boolean          default(FALSE)
#  cloned_from                        :string(22)
#  google_oauth2_id                   :string(255)
#  linkedin_id                        :string(255)
#
# Indexes
#
#  index_people_on_authentication_token               (authentication_token)
#  index_people_on_community_id                       (community_id)
#  index_people_on_community_id_and_google_oauth2_id  (community_id,google_oauth2_id)
#  index_people_on_community_id_and_linkedin_id       (community_id,linkedin_id)
#  index_people_on_email                              (email) UNIQUE
#  index_people_on_facebook_id                        (facebook_id)
#  index_people_on_facebook_id_and_community_id       (facebook_id,community_id) UNIQUE
#  index_people_on_google_oauth2_id                   (google_oauth2_id)
#  index_people_on_id                                 (id)
#  index_people_on_linkedin_id                        (linkedin_id)
#  index_people_on_reset_password_token               (reset_password_token) UNIQUE
#  index_people_on_username                           (username)
#  index_people_on_username_and_community_id          (username,community_id) UNIQUE
#  index_people_on_uuid                               (uuid) UNIQUE
#

require 'json'
require 'rest_client'
require "open-uri"

# This class represents a person (a user of Sharetribe).
class Person < ApplicationRecord

  include ErrorsHelper
  include ApplicationHelper
  include DeletePerson
  include Person::ToView

  self.primary_key = "id"

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable

  attr_accessor :guid, :form_login,
                :form_given_name, :form_family_name, :form_password,
                :form_password2, :form_email,
                :input_again, :send_notifications
  attr_writer :password2, :consent

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  has_many :listings, -> { exist }, :dependent => :destroy, :foreign_key => "author_id", :inverse_of => :author
  has_many :emails, :dependent => :destroy, :inverse_of => :person

  has_one :location, -> { where(location_type: :person) }, :dependent => :destroy, :inverse_of => :person

  has_many :participations, :dependent => :destroy
  has_many :conversations, :through => :participations, :dependent => :destroy
  has_many :authored_testimonials, :class_name => "Testimonial", :foreign_key => "author_id", :dependent => :destroy, :inverse_of => :author
  has_many :received_testimonials, -> { id_order.non_blocked }, :class_name => "Testimonial", :foreign_key => "receiver_id", :dependent => :destroy, :inverse_of => :receiver
  has_many :received_positive_testimonials, -> { positive.id_order.non_blocked }, :class_name => "Testimonial", :foreign_key => "receiver_id", :inverse_of => :receiver
  has_many :received_negative_testimonials, -> { negative.id_order.non_blocked }, :class_name => "Testimonial", :foreign_key => "receiver_id", :inverse_of => :receiver
  has_many :messages, :foreign_key => "sender_id", :dependent => :destroy, :inverse_of => :sender
  has_many :authored_comments, :class_name => "Comment", :foreign_key => "author_id", :dependent => :destroy, :inverse_of => :author
  belongs_to :community
  has_many :community_memberships, :dependent => :destroy
  has_many :communities, -> { where("community_memberships.status = 'accepted'") }, :through => :community_memberships
  has_one  :community_membership, :dependent => :destroy
  has_one  :accepted_community, -> { where("community_memberships.status= 'accepted'") }, through: :community_membership, source: :community
  has_many :invitations, :foreign_key => "inviter_id", :dependent => :destroy, :inverse_of => :inviter
  has_many :auth_tokens, :dependent => :destroy
  has_many :follower_relationships, :dependent => :destroy
  has_many :followers, :through => :follower_relationships, :foreign_key => "person_id"
  has_many :inverse_follower_relationships, :class_name => "FollowerRelationship", :foreign_key => "follower_id", :dependent => :destroy, :inverse_of => :follower
  has_many :followed_people, :through => :inverse_follower_relationships, :source => "person"

  has_and_belongs_to_many :followed_listings, :class_name => "Listing", :join_table => "listing_followers"
  has_many :custom_field_values, :dependent => :destroy
  has_many :custom_dropdown_field_values, :class_name => "DropdownFieldValue", :dependent => :destroy
  has_many :custom_checkbox_field_values, :class_name => "CheckboxFieldValue", :dependent => :destroy
  has_one :stripe_account, :dependent => :destroy
  has_one :paypal_account, :dependent => :destroy
  has_many :starter_transactions, :class_name => "Transaction", :foreign_key => "starter_id", :dependent => :destroy, :inverse_of => :starter
  has_many :payer_stripe_payments, :class_name => "StripePayment", :foreign_key => "payer_id", :dependent => :destroy, :inverse_of => :payer
  has_many :receiver_stripe_payments, :class_name => "StripePayment", :foreign_key => "receiver_id", :dependent => :destroy, :inverse_of => :receiver

  deprecate communities: "Use accepted_community instead.",
            community_memberships: "Use community_membership instead.",
            deprecator: MethodDeprecator.new

  scope :by_community, ->(community_id) { where(community_id: community_id) }
  scope :search_name_or_email, ->(community_id, pattern) {
    by_community(community_id)
      .joins(:emails)
      .where("#{Person.search_by_pattern_sql('people')}
        OR emails.address like :pattern", pattern: pattern)
  }
  scope :has_listings, ->(community) do
    joins("INNER JOIN `listings` ON `listings`.`author_id` = `people`.`id` AND `listings`.`community_id` = #{community.id} AND `listings`.`deleted` = 0").distinct
  end
  scope :has_no_listings, ->(community) do
    joins("LEFT OUTER JOIN `listings` ON `listings`.`author_id` = `people`.`id` AND `listings`.`community_id` = #{community.id} AND `listings`.`deleted` = 0")
    .where(listings: {author_id: nil}).distinct
  end
  scope :has_stripe_account, ->(community) do
    where(id: StripeAccount.active_users.by_community(community).select(:person_id))
  end
  scope :has_no_stripe_account, ->(community) do
    where.not(id: StripeAccount.active_users.by_community(community).select(:person_id))
  end
  scope :has_paypal_account, ->(community) do
    where(id: PaypalAccount.active_users.by_community(community).select(:person_id))
  end
  scope :has_no_paypal_account, ->(community) do
    where.not(id: PaypalAccount.active_users.by_community(community).select(:person_id))
  end
  scope :has_payment_account, ->(community) { has_stripe_account(community).or(has_paypal_account(community)) }
  scope :has_started_transactions, ->(community) do
    joins("INNER JOIN `transactions` ON `transactions`.`starter_id` = `people`.`id` AND `transactions`.`community_id` = #{community.id} AND `transactions`.`current_state` IN ('paid', 'confirmed')").distinct
  end
  scope :is_admin, -> { where(is_admin: 1) }
  scope :by_email, ->(email) do
    joins(:emails).merge(Email.confirmed.by_address(email))
  end
  scope :by_unconfirmed_email, ->(email) do
    joins(:emails).merge(Email.unconfirmed.by_address(email))
  end
  scope :username_exists, ->(username, community) do
    where("username = :username AND (is_admin = '1' OR community_id = :cid)", username: username, cid: community.id)
  end

  accepts_nested_attributes_for :custom_field_values

  def to_param
    username
  end

  DEFAULT_TIME_FOR_COMMUNITY_UPDATES = 7.days

  # These are the email notifications, excluding newsletters settings
  EMAIL_NOTIFICATION_TYPES = [
    "email_about_new_messages",
    "email_about_new_comments_to_own_listing",
    "email_when_conversation_accepted",
    "email_when_conversation_rejected",
    "email_about_new_received_testimonials",
    "email_about_confirm_reminders",
    "email_about_testimonial_reminders",
    "email_about_completed_transactions",
    "email_about_new_payments",
    "email_about_new_listings_by_followed_people"

    # These should not yet be shown in UI, although they might be stored in DB
    # "email_when_new_friend_request",
    # "email_when_new_feedback_on_transaction",
    # "email_when_new_listing_from_friend"
  ]
  EMAIL_NEWSLETTER_TYPES = [
    "email_from_admins"
  ]

  serialize :preferences

  validates_length_of :phone_number, :maximum => 25, :allow_nil => true, :allow_blank => true
  validates_length_of :given_name, :within => 1..30, :allow_nil => true, :allow_blank => true
  validates_length_of :family_name, :within => 1..30, :allow_nil => true, :allow_blank => true
  validates_length_of :display_name, :within => 1..100, :allow_nil => true, :allow_blank => true

  USERNAME_BLACKLIST = YAML.load_file("#{Rails.root}/config/username_blacklist.yml")

  validates :username, exclusion: {in: USERNAME_BLACKLIST, message: :username_is_invalid},
                       uniqueness: {scope: :community_id},
                       length: {within: 3..20},
                       format: {with: /\A[A-Z0-9_]*\z/i, message: :username_is_invalid}

  has_attached_file :image, :styles => {
                      :medium => "288x288#",
                      :small => "108x108#",
                      :thumb => "48x48#",
                      :original => "600x800>"}

  process_in_background :image

  #validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 9.megabytes
  validates_attachment_content_type :image,
                                    :content_type => IMAGE_CONTENT_TYPE

  before_validation(:on => :create) do
    self.id = SecureRandom.urlsafe_base64
    self.username = self.username.presence || UserService::API::Users.generate_username(given_name, family_name, community_id)
    set_default_preferences unless self.preferences
  end

  after_initialize :add_uuid
  def add_uuid
    self.uuid ||= UUIDUtils.create_raw
  end

  def uuid_object
    if self[:uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:uuid])
    end
  end

  # Creates a new email
  def email_attributes=(attributes)
    ActiveSupport::Deprecation.warn(
      ["Person.email_attributes is deprecated.",
       "Instead of using nested attributes, build each associated",
       "model individually inside a DB transaction in the controller."].join(" "))

    emails.build(attributes)
  end

  def set_emails_that_receive_notifications(email_ids)
    if email_ids
      emails.each do |email|
        email.update_attribute(:send_notifications, email_ids.include?(email.id.to_s))
      end
    end
  end

  def last_community_updates_at
    community_updates_last_sent_at || DEFAULT_TIME_FOR_COMMUNITY_UPDATES.ago
  end

  def self.username_blacklist
    USERNAME_BLACKLIST
  end

  def self.username_available?(username, community, current_user = nil)
    current_scope = current_user ? self.where.not(id: current_user.id) : self
    !USERNAME_BLACKLIST.include?(username.downcase) &&
      !current_scope.username_exists(username, community).present?
  end

  def set_given_name(name)
    update({:given_name => name })
  end

  def street_address
    if location
      return location.address
    else
      return nil
    end
  end

  def custom_update(params)
    if params[:preferences]
      update(params)
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
      update(params.except("password2", "street_address"))
    end
  end

  def picture_from_url(url)
    self.image = open(url) # rubocop:disable Security/Open
    self.save
  end

  def offers
    listings.offers
  end

  def requests
    listings.requests
  end

  def feedback_positive_percentage_in_community(community)
    received = received_testimonials.by_community(community)
    positive = received_positive_testimonials.by_community(community)
    negative = received_negative_testimonials.by_community(community)

    if positive.size > 0
      if negative.size > 0
        (positive.size.to_f/received.size.to_f*100).round
      else
        return 100
      end
    elsif negative.size > 0
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
      return form_password2 || ""
    end
  end

  def can_delete_email(email)
    EmailService.can_delete_email(self.emails,
                                  email,
                                  self.accepted_community.allowed_emails)[:result]
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

  def consent
    community_membership.consent
  end

  def is_marketplace_admin?(community)
    community_membership.community_id == community.id && community_membership.admin?
  end

  def has_admin_rights?(community)
    is_admin? || is_marketplace_admin?(community)
  end

  def should_receive?(email_type)
    confirmed_email = !confirmed_notification_emails.empty?
    if email_type == "community_updates"
      # this is handled outside prefenrences so answer separately
      return confirmed_email && min_days_between_community_updates < 100000
    end

    confirmed_email && preferences && preferences[email_type]
  end

  def profile_info_empty?
    (phone_number.nil? || phone_number.blank?) && (description.nil? || description.blank?) && location.nil?
  end

  def member_of?(community)
    community.members.include?(self)
  end

  def banned?
    community_membership.banned?
  end

  def has_email?(address)
    Email.find_by_address_and_person_id(address, self.id).present?
  end

  def confirmed_notification_emails
    emails.send_notifications.confirmed
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

  # Primary email is the first email address that is
  #
  # - confirmed
  # - notifications allowed
  #
  # Returns Email record
  #
  def primary_email
    EmailService.emails_to_send_message(emails).first
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

  def self.find_by_email_address_and_community_id(email_address, community_id)
    Maybe(
      Email.find_by_address_and_community_id(email_address, community_id)
    ).person.or_else(nil)
  end

  def reset_password_token_if_needed
    # Devise 3.1.0 doesn't expose methods to generate reset_password_token without
    # sending the email, so this code is copy-pasted from Recoverable module
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(:validate => false)
    raw
  end

  # If image_file_name is null, it means the user
  # does not have a profile picture.
  def has_profile_picture?
    image_file_name.present?
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
    self.min_days_between_community_updates = current_community.default_min_days_between_community_updates
  end

  def should_receive_community_updates_now?
    return false unless should_receive?("community_updates")
    # return whether or not enought time has passed. The - 45.minutes is because the sending takes some time so we want
    # 1 day limit to match even if there's 23.55 minutes passed since last sending.
    return true if community_updates_last_sent_at.nil?

    return community_updates_last_sent_at + min_days_between_community_updates.days - 45.minutes < Time.now
  end

  # Returns and email that is pending confirmation
  # If community is given as parameter, in case of many pending
  # emails the one required by the community is returned
  def latest_pending_email_address(community=nil)
    pending_emails = Email.where(:person_id => id, :confirmed_at => nil).pluck(:address)

    allowed_emails = if community&.allowed_emails
      pending_emails.select do |e|
        community.email_allowed?(e)
      end
    else
      pending_emails
    end

    allowed_emails.last
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


  # Overrides method injected from Devise::DatabaseAuthenticatable
  # Updates password with password that has been rehashed with new algorithm.
  # Removes legacy password and salt.
  def valid_password?(password)
    if self.legacy_encrypted_password.present?
      if digest(password, self.password_salt).casecmp(self.legacy_encrypted_password) == 0
        self.password = password
        self.legacy_encrypted_password = nil
        self.password_salt = nil
        self.save!
        true
      else
        false
      end
    else
      super
    end
  end

  # Overrides method injected from Devise::DatabaseAuthenticatable
  # Removes legacy pashsword and salt.
  def password=(*args)
    self.legacy_encrypted_password = nil
    self.password_salt = nil
    super
  end

  def unsubscribe_from_community_updates
    self.min_days_between_community_updates = 100000
    self.save!
  end

  def custom_field_value_for(custom_field)
    custom_field_values.by_question(custom_field).first
  end

  private

  def digest(password, salt)
    str = [password, salt].flatten.compact.join
    ::Digest::SHA256.hexdigest(str)
  end

  def logger
    @logger ||= SharetribeLogger.new(:person, logger_metadata.keys).tap { |logger|
      logger.add_metadata(logger_metadata)
    }
  end

  def logger_metadata
    { person_uuid: uuid }
  end

  class << self
    def search_by_pattern_sql(table, pattern=':pattern')
      "(#{table}.given_name LIKE #{pattern} OR #{table}.family_name LIKE #{pattern} OR #{table}.display_name LIKE #{pattern})"
    end
  end
end
