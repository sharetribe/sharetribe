# == Schema Information
#
# Table name: invitations
#
#  id           :integer          not null, primary key
#  code         :string(255)
#  community_id :integer
#  usages_left  :integer
#  valid_until  :datetime
#  information  :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  inviter_id   :string(255)
#  message      :text(65535)
#  email        :string(255)
#
# Indexes
#
#  index_invitations_on_code        (code)
#  index_invitations_on_inviter_id  (inviter_id)
#

# Invitation stores the invitation (and codes) that people need to join certain communities

class Invitation < ApplicationRecord

  INVITATION_LIMIT = 10
  INVITE_ONLY_INVITATION_LIMIT = 50

  has_many :community_memberships #One invitation can result many users joining.
  belongs_to :community
  belongs_to :inviter, :class_name => "Person", :foreign_key => "inviter_id"

  validates_presence_of :community_id # The invitation must relate to one community

  validates_presence_of :code #generated automatically
  validates_uniqueness_of :code

  validates_length_of :message, :maximum => 5000, :allow_nil => true

  before_validation(:on => :create) do
    self.code ||= ApplicationHelper.random_sting.upcase
    self.usages_left ||= 1
  end

  def usable?
    return usages_left > 0 && (valid_until.nil? || valid_until > DateTime.now)
  end

  def use_once!
    raise "Invitation is not usable" if not usable?
    update_attribute(:usages_left, self.usages_left - 1)
  end

  def self.code_usable?(code, community=nil)
    invitation = Invitation.find_by_code(code.upcase) if code.present?
    if invitation.present?
      return false if community.present? && invitation.community_id != community.id
      return invitation.usable?
    else
      return false
    end
  end

  def self.use_code_once(code)
    invitation = Invitation.find_by_code(code.upcase) if code.present?
    return false if invitation.blank?
    invitation.use_once!
    return true
  end

  def self.invitation_limit
    return INVITATION_LIMIT
  end

  def self.invite_only_invitation_limit
    return INVITE_ONLY_INVITATION_LIMIT
  end

end
