# == Schema Information
#
# Table name: auth_tokens
#
#  id               :integer          not null, primary key
#  token            :string(255)
#  person_id        :string(255)
#  expires_at       :datetime
#  last_use_attempt :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_auth_tokens_on_token  (token) UNIQUE
#

class AuthToken < ActiveRecord::Base
  belongs_to :person
  after_initialize :defaults

  attr_accessible :person, :expires_at

  validates_presence_of :person_id
  validates_presence_of :expires_at
  validates_uniqueness_of :token

  def defaults
    self.token ||= SecureRandom.urlsafe_base64(8)
  end

  def self.delete_expired
    where("expires_at < ?", 1.week.ago ).delete_all
  end

end
