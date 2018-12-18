# == Schema Information
#
# Table name: emails
#
#  id                   :integer          not null, primary key
#  person_id            :string(255)
#  community_id         :integer          not null
#  address              :string(255)      not null
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  confirmation_token   :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  send_notifications   :boolean
#
# Indexes
#
#  index_emails_on_address                   (address)
#  index_emails_on_address_and_community_id  (address,community_id) UNIQUE
#  index_emails_on_community_id              (community_id)
#  index_emails_on_confirmation_token        (confirmation_token)
#  index_emails_on_person_id                 (person_id)
#

class Email < ApplicationRecord

  include ApplicationHelper
  belongs_to :person

  validates_presence_of :person
  validates_length_of :address, :maximum => 255
  validates_format_of :address,
                       :with => /\A[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]+\z/i

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  before_save do
    #force email to be lower case
    self.address = self.address.downcase
    if not confirmed_at
      self.confirmation_token ||= SecureRandom.base64(12)
    end
  end

  def confirm!
    self.confirmed_at = Time.now
    self.save
  end

  # Email already in use for current user or someone else
  def self.email_available?(email, community_id)
    !Email
      .joins("LEFT OUTER JOIN people ON emails.person_id = people.id")
      .where("emails.address = :email AND (people.is_admin = '1' OR people.community_id = :cid)", email: email, cid: community_id)
      .present?
  end

  def self.send_confirmation(email, community)
    Delayed::Job.enqueue(EmailConfirmationJob.new(email.id, community.id), priority: 2)
  end

  def self.find_by_address_and_community_id(address, community_id)
    Email
      .joins("INNER JOIN community_memberships ON community_memberships.person_id = emails.person_id")
      .find_by(address: address, community_memberships: { community_id: community_id })
  end

  def self.unsubscribe_email_from_community_updates(email_address)
    Email.where(address: email_address).map(&:person).each(&:unsubscribe_from_community_updates)
  end
end
