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

  def domain_possible?
    white_label? && !use_domain?
  end

  def update
    community.ident = params[:community][:ident]&.downcase
    community.save
  end

  def create_domain_setup
    domain = params.try(:[], :community).try(:[], :domain)
    if domain.present?
      ascii_domain = begin
                       SimpleIDN.to_ascii(domain)
                     rescue Exception
                       return false
                     end
      s = DomainSetup.create(domain: ascii_domain.downcase,
                             state: DomainSetup::CHECK_PENDING,
                             community: community)
      s if s && s.persisted?
    end
  end

  def recheck_domain_setup
    community.domain_setup.recheck_setup!
  end

  def confirm_domain_setup
    community.domain_setup.confirm_setup!
  end

  def retry_domain_setup
    community.domain_setup.retry_setup!
  end

  def reset
    community.domain_setup&.destroy
    community.reload
  end
end
