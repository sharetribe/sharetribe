# == Schema Information
#
# Table name: community_memberships
#
#  id                  :integer          not null, primary key
#  person_id           :string(255)      not null
#  community_id        :integer          not null
#  admin               :boolean          default(FALSE)
#  created_at          :datetime
#  updated_at          :datetime
#  consent             :string(255)
#  invitation_id       :integer
#  last_page_load_date :datetime
#  status              :string(255)      default("accepted"), not null
#  can_post_listings   :boolean          default(FALSE)
#
# Indexes
#
#  community_person_status                      (community_id,person_id,status)
#  index_community_memberships_on_community_id  (community_id)
#  index_community_memberships_on_person_id     (person_id) UNIQUE
#

class CommunityMembership < ApplicationRecord

  VALID_STATUSES = [
    ACCEPTED = "accepted".freeze,
    PENDING_EMAIL_CONFIRMATION = "pending_email_confirmation".freeze,
    PENDING_CONSENT = "pending_consent".freeze,
    BANNED = "banned".freeze,
    DELETED_USER = "deleted_user".freeze
  ].freeze

  belongs_to :person
  belongs_to :community, :counter_cache => :members_count
  belongs_to :invitation

  attr_accessor :email

  before_create :set_last_page_load_date_to_current_time

  validate :person_can_join_community_only_once, :on => :create
  validates_inclusion_of :status, :in => VALID_STATUSES

  scope :accepted, -> { where(status: ACCEPTED) }
  scope :banned, -> { where(status: BANNED) }
  scope :accepted_or_banned, -> { where(status: [ACCEPTED, BANNED]) }
  scope :admin, -> { where(admin: true) }
  scope :posting_allowed, -> { where(can_post_listings: true) }
  scope :not_banned, -> { where("community_memberships.status <> ?", [BANNED]) }
  scope :not_deleted_user, -> { where.not(status: DELETED_USER) }
  scope :not_accepted, -> { where.not(status: ACCEPTED) }
  scope :pending_email_confirmation, -> { where(status: PENDING_EMAIL_CONFIRMATION) }
  scope :pending_consent, -> { where(status: PENDING_CONSENT) }

  def person_can_join_community_only_once
    if CommunityMembership.find_by_person_id_and_community_id(person_id, community_id)
      errors.add(:base, "You are already a member of this community")
    end
  end

  def set_last_page_load_date_to_current_time
    self.last_page_load_date = DateTime.now
  end

  def accepted?
    status == ACCEPTED
  end

  def pending_consent?
    status == PENDING_CONSENT
  end

  def pending_email_confirmation?
    status == PENDING_EMAIL_CONFIRMATION
  end

  def pending?
    not accepted?
  end

  def banned?
    status == BANNED
  end
end
