# Invitation stores the invitation (and codes) that people need to join certain communities

class Invitation < ActiveRecord::Base
  
  #include ApplicationHelper
  
  has_many :community_memberships #One invitation can result many users joining.
  belongs_to :community
  
  validates_presence_of :community_id # The invitation must relate to one community
  
  validates_presence_of :code #generated automatically
  validates_uniqueness_of :code
  
  def after_initialize
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

end
