class Organization < ActiveRecord::Base
  attr_accessible :allowed_emails, :name, :logo, :company_id
  
  has_many :organization_memberships, :dependent => :destroy
  has_many :members, :through => :organization_memberships, :source => :person
  has_many :listings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  paperclip_options_for_logo = PaperclipHelper.paperclip_default_options.merge!({:styles => {  
                      :medium => "288x288#",
                      :small => "108x108#",
                      :thumb => "48x48#", 
                      :original => "600x600>"},
                      :default_url => "/logos/header/default.png"
  })
  
  has_attached_file :logo, paperclip_options_for_logo
  
  
  def has_admin?(person)
    membership = OrganizationMembership.find_by_person_id_and_organization_id(person.id, self.id) 
    membership.present? && membership.admin
  end
  
  def register_a_merchant_account
    # Call Checkout Finland API here
    puts "MERCHANT REGISTRATION CALLED BUT NOT YET IMPLEMENTED"
    
  end
  
  def has_member?(person)
    members.include?(person)
  end
  
  def merchant_id
    "375917"
  end
  
  def merchant_security_key
    "SAIPPUAKAUPPIAS"
  end
end
