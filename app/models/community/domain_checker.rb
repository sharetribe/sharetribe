# == Schema Information
#
# Table name: community_domain_checkers
#
#  id           :bigint           not null, primary key
#  community_id :bigint
#  domain       :string(255)
#  state        :string(255)      default(NULL)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_community_domain_checkers_on_community_id  (community_id)
#

class Community::DomainChecker < ApplicationRecord
  belongs_to :community

  CHECKING = {
    INITIAL = 'initial'.freeze => 'initial'.freeze,
    PENDING = 'pending'.freeze => 'pending'.freeze,
    PASSED = 'passed'.freeze => 'passed'.freeze,
    FAILED = 'failed'.freeze => 'failed'.freeze,
    PASSED_WITH_WARNING = 'passed_with_warning'.freeze => 'passed_with_warning'.freeze
  }
  enum state: CHECKING

  def check
    pending!
    run_background_task
  end

  private

  def run_background_task
    case domain
    when 'pending.example.com'
      pending!
    when 'not.example.com'
      failed!
    when 'www.example.com'
      passed!
    when 'warning.example.com'
      passed_with_warning!
    else
      pending!
    end
  end
end
