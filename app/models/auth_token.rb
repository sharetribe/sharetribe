class AuthToken < ActiveRecord::Base
  belongs_to :person
  
  before_validation(:on => :create) do
    self.token = SecureRandom.base64(12) unless self.token
  end

end