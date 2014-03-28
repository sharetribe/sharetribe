class CommunityMembership < ActiveRecord::Base

  VALID_STATUSES = ["accepted", "pending_email_confirmation", "banned"]

  belongs_to :person
  belongs_to :community, :counter_cache => :members_count
  belongs_to :invitation

  attr_accessor :email

  attr_protected :admin

  before_create :set_last_page_load_date_to_current_time

  validate :person_can_join_community_only_once, :on => :create
  validates_inclusion_of :status, :in => VALID_STATUSES

  def person_can_join_community_only_once
    if CommunityMembership.find_by_person_id_and_community_id(person_id, community_id)
      errors.add(:base, "You are already a member of this community")
    end
  end

  def set_last_page_load_date_to_current_time
    self.last_page_load_date = DateTime.now
  end

  def accepted?
    status == "accepted"
  end

  def pending_email_confirmation?
    status == "pending_email_confirmation"
  end

  def pending?
    not accepted?
  end

  def banned?
    status == "banned"
  end

  def current_terms_accepted?
    consent.present? && consent == community.consent
  end

end
