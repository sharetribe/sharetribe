class Email < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :person
  
  validates_presence_of :person
  validates_uniqueness_of :address
  validates_format_of :address,
                       :with => /^[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
  
  before_save do
    if not confirmed_at
      self.confirmation_token ||= ActiveSupport::SecureRandom.base64(12)
    end
  end
  
  def self.confirmed?(email)
    Email.find_by_address(email).confirmed_at.present?
  end
  
end