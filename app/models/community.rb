class Community < ActiveRecord::Base

  has_many :community_memberships, :dependent => :destroy 
  has_many :members, :through => :community_memberships, :class_name => "Person", :foreign_key => :member_id
  
  has_and_belongs_to_many :listings
  
  validates_length_of :name, :in => 2..50
  validates_length_of :domain, :in => 2..30
  validates_format_of :domain, :with => /^[A-Z0-9_-]*$/i
  
  serialize :settings, Hash


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
