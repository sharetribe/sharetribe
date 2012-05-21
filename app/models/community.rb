class Community < ActiveRecord::Base

  has_many :community_memberships, :dependent => :destroy 
  has_many :members, :through => :community_memberships, :source => :person, :foreign_key => :member_id
  has_many :invitations, :dependent => :destroy
  has_many :news_items
  has_many :polls
  has_many :event_feed_events
  has_one :location, :dependent => :destroy
  
  has_and_belongs_to_many :listings
  
  VALID_CATEGORIES = ["company", "university", "association", "neighborhood", "congregation", "town", "apartment_building", "other"]
  
  validates_length_of :name, :in => 2..50
  validates_length_of :domain, :in => 2..50
  validates_format_of :domain, :with => /^[A-Z0-9_-]*$/i
  validates_uniqueness_of :domain
  validates_length_of :slogan, :in => 2..100
  validates_length_of :description, :in => 2..500
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  
  # The settings hash contains some community specific settings:
  # locales: which locales are in use, the first one is the default
  # asi_welcome_mail: boolean that tells if ASI should send the welcome mail to newly registered user. Default is false.
    
  serialize :settings, Hash
  
  def address
    location ? location.address : nil
  end
  
  def default_locale
    if settings && !settings["locales"].blank?
      return settings["locales"].first
    else
      return APP_CONFIG.default_locale
    end
  end
  
  def locales
   if settings && !settings["locales"].blank?
      return settings["locales"]
    else
      # if locales not set, return the short locales from the default list
      return APP_CONFIG.available_locales.collect{|loc| loc[1]}
    end
  end
  
  # Return the people who are admins of this community
  def admins
    members.joins(:community_memberships).where("community_memberships.admin = '1'").group("people.id")
  end
  
  # Returns the emails of admins in an array
  def admin_emails
    admins.collect { |p| p.email }
  end
  
  # returns if ASI welcome mail is used for this community
  # defaults to false if that setting is not set
  def use_asi_welcome_mail?
    if settings && settings["asi_welcome_mail"] == true
      return true
    else
      return false
    end
  end
  
  # If community name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def name_with_separator(locale)
    (name.include?(" ") && locale.to_s.eql?("fi")) ? "#{name} " : name
  end
  
  def active_poll
    polls.where(:active => true).first
  end
  
  def set_email_confirmation_on_and_send_mail_to_existing_users
    # If email confirmation is already active, do nothing
    return if self.email_confirmation == true
    
    self.email_confirmation = true
    save
    
    original_locale = I18n.locale
    
    #Store host to global variable to be able to use this from console
    $host = "#{self.domain}.#{APP_CONFIG.weekly_email_domain}"
    
    members.all.each do |member|
      member.confirmed_at = nil
      member.save
      I18n.locale = member.locale
      member.send_confirmation_instructions
      
    end
    I18n.locale = original_locale
  end
  
  # Makes the creator of the community a member and an admin
  def admin_attributes=(attributes)
    community_memberships.build(attributes)
  end
  
  def self.domain_available?(domain)
    ! find_by_domain(domain).present?
  end

end
