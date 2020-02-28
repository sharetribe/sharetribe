class Admin::DomainsService
  attr_reader :community, :plan, :params

  delegate :use_domain?, :ident, :domain, to: :community, prefix: false

  def initialize(community:, plan:, params:)
    @community = community
    @plan = plan
    @params = params
  end

  def ident_available?
    !Community.find_by(ident: params[:community][:ident])
  end

  def white_label?
    !!plan.try(:[], :features).try(:[], :whitelabel)
  end

  def update
    community.ident = params[:community][:ident]&.downcase
    community.save
  end

  # always perform full domain check
  def check_domain_availability
    domain_checker = community.domain_checker || community.create_domain_checker
    if params.try(:[], :community).try(:[], :domain).present?
      domain_checker.update_column(:domain, params[:community][:domain]&.downcase) # rubocop:disable Rails/SkipsModelValidations
    end
    domain_checker.check
    domain_checker.state
  end

  def reset
    community.domain_checker.destroy
    community.reload
  end
end
