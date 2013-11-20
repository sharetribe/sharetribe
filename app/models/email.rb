class Email < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :person
  
  validates_presence_of :person
  validates_uniqueness_of :address
  validates_length_of :address, :maximum => 255
  validates_format_of :address,
                       :with => /^[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
  
  before_save do
    if not confirmed_at
      self.confirmation_token ||= SecureRandom.base64(12)
    end
  end
  
  def self.confirmed?(email)
    Email.find_by_address(email).confirmed_at.present?
  end
  
  def self.email_available?(email)
    !Email.find_by_address(email).present?
  end

  def self.email_available_for_user?(user, address)
    email = Email.find_by_address(address)
    !email.present? || email.person == user
  end

  def self.send_confirmation(email, host, community=nil)
    PersonMailer.email_confirmation(email, host, community).deliver
  end
end