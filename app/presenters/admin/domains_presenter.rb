class Admin::DomainsPresenter
  attr_reader :community, :plan

  delegate :use_domain?, :ident, :domain, to: :community, prefix: false

  def initialize(community:, plan:)
    @community = community
    @plan = plan
  end

  def domain_disabled?
    !white_label?
  end

  def domain_possible?
    white_label? && !use_domain?
  end

  def domain_used?
    white_label? && use_domain?
  end

  def domain_address
    domain_used? ? "https://#{domain}" : "https://#{ident}.sharetribe.com"
  end

  private

  def white_label?
    plan ? !!plan[:features][:whitelabel] : false
  end
end
