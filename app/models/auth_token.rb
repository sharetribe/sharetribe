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
