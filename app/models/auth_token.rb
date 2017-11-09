# == Schema Information
#
# Table name: auth_tokens
#
#  id               :integer          not null, primary key
#  token            :string(255)
#  token_type       :string(255)      default("unsubscribe")
#  person_id        :string(255)
#  expires_at       :datetime
#  usages_left      :integer
#  last_use_attempt :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_auth_tokens_on_token  (token) UNIQUE
#

class AuthToken < ApplicationRecord
  belongs_to :person
  after_initialize :defaults

  validates_presence_of :person_id
  validates_presence_of :expires_at
  validates_uniqueness_of :token
  validates_inclusion_of :token_type, :in => ["unsubscribe", "login"]

  def defaults
    self.token ||= SecureRandom.urlsafe_base64(8)
    self.usages_left ||= 1
    self.token_type ||= "unsubscribe"
  end

  def self.delete_expired
    where("expires_at < ?", 4.weeks.ago).delete_all
  end

  def self.create_unsubscribe_token(person_id:, expires_at: 4.weeks.from_now)
    create(
      person_id: person_id,
      expires_at: expires_at,
      token_type: "unsubscribe"
    )
  end

end
