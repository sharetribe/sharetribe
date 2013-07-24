# encoding: UTF-8

# This class is currently used by only one specific client
# The plan is to separate this code later to a plugin

class Organization < ActiveRecord::Base
  
  include EmailHelper
    
  attr_accessible :allowed_emails, :name, :logo, :company_id,
                  :email, :phone_number, :website, :address, :merchant_registration
  
  attr_accessor :email, :phone_number, :website, :address, :merchant_registration
  
  has_many :organization_memberships, :dependent => :destroy
  has_many :members, :through => :organization_memberships, :source => :person
  has_many :listings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :company_id, :with => /^(\d{7}\-\d)?$/, :allow_nil => true
  
  paperclip_options_for_logo = PaperclipHelper.paperclip_default_options.merge!({:styles => {  
                      :medium => "288x288",
                      :small => "108x108",
                      :thumb => "48x48", 
                      :original => "600x600>"},
                      :default_url => "/assets/organizations/medium/default.png"
  })
  
  has_attached_file :logo, paperclip_options_for_logo
  validates_attachment_content_type :logo,
                                    :content_type => ["image/jpeg",
                                                      "image/png", 
                                                      "image/gif", 
                                                      "image/pjpeg", 
                                                      "image/x-png"]
  
  
  def has_admin?(person)
    return false if person.nil?
    membership = OrganizationMembership.find_by_person_id_and_organization_id(person.id, self.id) 
    membership.present? && membership.admin
  end
  
  def register_a_merchant_account
    url = "https://rpcapi.checkout.fi/reseller/createMerchant"
    user = APP_CONFIG.merchant_api_user_id
    password = APP_CONFIG.merchant_api_password

    if APP_CONFIG.merchant_registration_mode == "production"
      type = 0 # Creates real merchant accounts
    else
      type = 2 # Creates test accounts
    end
         
    api_params = {
      "company" => name,
      "vat_id"  => company_id,
      "name"    => name,
      "email"   => email,
      "gsm"     => phone_number,
      "type"    => type,
      "info"    => "Materiaalipankki",
      "address" => address,
      "url"     => website,
      "kkhinta" => "0",
    }
    
    if APP_CONFIG.merchant_registration_mode == "production" || APP_CONFIG.merchant_registration_mode == "test" 
      response = RestClient::Request.execute(:method => :post, :url => url, :user => user, :password => password, :payload => api_params)
    else
      # Stub response to avoid unnecessary accounts being created (unless config is set to make real accounts)
      #puts "STUBBING A CALL TO MERCHANT API WITH PARAMS: #{api_params.inspect}"
      response = "<merchant><id>375917</id><secret>SAIPPUAKAUPPIAS</secret><banner>http://rpcapi.checkout.fi/banners/5a1e9f504277f6cf17a7026de4375e97.png</banner></merchant>"
    end

    self.merchant_id = response[/<id>([^<]+)<\/id>/, 1]
    self.merchant_key = response[/<secret>([^<]+)<\/secret>/, 1]
    save!
    
    if self.merchant_id && self.merchant_key
      return true
    else
      return false
    end
  end
  
  def has_member?(person)
    members.include?(person)
  end
  
  def is_registered_as_seller?
    self.merchant_id.present? && self.merchant_key.present?
  end
end
