class AuthToken < ActiveRecord::Base
  belongs_to :person

  validates_presence_of :person_id
  validates_presence_of :times_used
  validates_uniqueness_of :token

  before_validation(:on => :create) do
    self.token ||= SecureRandom.urlsafe_base64(8)
    self.expires_at ||= 1.week.from_now
    self.times_used ||= 0
  end

  def self.delete_expired
    where("expires_at < ?", 1.week.ago ).delete_all
  end

end
