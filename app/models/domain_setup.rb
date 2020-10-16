# == Schema Information
#
# Table name: domain_setups
#
#  id             :bigint           not null, primary key
#  community_id   :bigint
#  domain         :string(255)      not null
#  state          :string(255)      not null
#  error          :string(255)
#  critical_error :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_domain_setups_on_community_id          (community_id) UNIQUE
#  index_domain_setups_on_critical_error        (critical_error)
#  index_domain_setups_on_state_and_updated_at  (state,updated_at)
#

class DomainSetup < ApplicationRecord
  belongs_to :community

  STATE = {
    CHECK_PENDING = 'check_pending'.freeze => 'check-pending'.freeze,
    CHECK_OK = 'check_ok'.freeze => 'check-ok'.freeze,
    CHECK_OK_REDIRECT_WARNING = 'check_ok_redirect-warning'.freeze => 'check-ok-redirect-warning'.freeze,
    CHECK_FAILED = 'check_failed'.freeze => 'check-failed'.freeze,
    SETUP_PENDING = 'setup_pending'.freeze => 'setup-pending'.freeze,
    SETUP_FAILED = 'setup_failed'.freeze => 'setup-failed'.freeze
  }

  enum state: STATE

  DOMAIN_REGEX = /(?!(sharetribe|sharetri\.be))(?=.{4,253})(\A((?!-)[a-z0-9-]{1,63}(?<!-)\.)+((?![0-9]+\z)(?!-)[a-z0-9-]{1,63}(?<!-)))\z/

  validates :community_id, uniqueness: true
  validates :domain,
            length:     { in: 4..253 },
            format:     { with: DOMAIN_REGEX, message: :domain_name_is_invalid },
            uniqueness: true
  validate :domain_is_globally_unique?

  def recheck_setup!
    if [CHECK_OK_REDIRECT_WARNING, CHECK_FAILED].include?(state)
      check_pending!
    end
  end

  def confirm_setup!
    if [CHECK_OK_REDIRECT_WARNING, CHECK_OK].include?(state)
      setup_pending!
    end
  end

  def retry_setup!
    setup_pending! if state == SETUP_FAILED
  end

  def domain_is_globally_unique?
    if Community.find_by_domain(self.domain)
      errors.add(:domain, :domain_name_is_invalid)
    end
  end

  class << self
    def critical_error?
      self.where(critical_error: true).exists?
    end
  end
end
