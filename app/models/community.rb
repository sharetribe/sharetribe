class Community < ActiveRecord::Base

  has_many :community_memberships, :dependent => :destroy 
  has_many :members, :through => :community_memberships, :source => :person, :foreign_key => :member_id
  
  has_and_belongs_to_many :listings
  
  validates_length_of :name, :in => 2..50
  validates_length_of :domain, :in => 2..30
  validates_format_of :domain, :with => /^[A-Z0-9_-]*$/i
  
  # The settings hash contains some community specific settings:
  # locales: which locales are in use, the first one is the default
  # asi_welcome_mail: boolean that tells if ASI should send the welcome mail to newly registered user. Default is false.
    
  serialize :settings, Hash
  
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
  
  # returns if ASI welcome mail is used for this community
  # defaults to false if that setting is not set
  def use_asi_welcome_mail?
    if settings && settings["asi_welcome_mail"] == true
      return true
    else
      return false
    end
  end

end
