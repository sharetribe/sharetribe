# == Schema Information
#
# Table name: auth_tokens
#
#  id               :integer          not null, primary key
#  token            :string(255)
#  person_id        :string(255)
#  expires_at       :datetime
#  times_used       :integer
#  last_use_attempt :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class AuthToken < ActiveRecord::Base
  belongs_to :person

  validates_presence_of :person_id
  validates_presence_of :times_used
  validates_uniqueness_of :token

  before_validation(:on => :create) do
    self.token ||= SecureRandom.urlsafe_base64(8)
    self.expires_at ||= 24.hours.from_now
    self.times_used ||= 0
  end

  def self.delete_expired
    # Delete only tokens older than one week as unsubscribe is allowed with a bit updated token too. :)
    where("expires_at < ?", 1.week.ago ).delete_all
  end

end
