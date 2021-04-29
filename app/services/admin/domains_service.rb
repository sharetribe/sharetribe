class Admin::DomainsService
  attr_reader :community, :plan, :params

  delegate :use_domain?, :ident, :domain, to: :community, prefix: false

  def initialize(community:, plan:, params:)
    @community = community
    @plan = plan
    @params = params
  end

  def community_url
    "#{APP_CONFIG.always_use_ssl ? 'https' : 'http'}://#{ident}.#{APP_CONFIG.domain}"
  end

  def ident_available?
    !Community.find_by(ident: params[:community][:ident])
  end

  def white_label?
    !!plan.try(:[], :features).try(:[], :whitelabel)
  end

  def trial?
    plan.try(:[], :status) == :trial && !plan.try(:[], :expired)
  end

  def domain_possible?
    white_label? && !use_domain?
  end

  def update
    old = community_url.deep_dup
    community.ident = params[:community][:ident]&.downcase
    if community.save
      notice_about_new_ident(old, community_url)
    end
  end

  def notice_about_new_ident(old, new)
    return true if old == new

    Delayed::Job.enqueue(IdentChangedJob.new(community.id, old, new))
  end

  def create_domain_setup
    return unless domain_possible?

    domain = params.try(:[], :community).try(:[], :domain)
    if domain.present?
      ascii_domain = begin
                       SimpleIDN.to_ascii(domain)
                     rescue StandardError
                       return
                     end
      s = DomainSetup.create(domain: ascii_domain.downcase,
                             state: DomainSetup::CHECK_PENDING,
                             community: community)
      s if s&.persisted?
    end
  end

  def recheck_domain_setup
    return unless domain_possible?

    community.domain_setup.recheck_setup!
  end

  def confirm_domain_setup
    return unless domain_possible?

    community.domain_setup.confirm_setup!
  end

  def retry_domain_setup
    return unless domain_possible?

    community.domain_setup.retry_setup!
  end

  def reset
    return unless domain_possible?

    if [DomainSetup::CHECK_FAILED,
        DomainSetup::CHECK_PASSED,
        DomainSetup::CHECK_PASSED_REDIRECT_WARNING,
        DomainSetup::SETUP_FAILED].include?(community.domain_setup&.state)
      community.domain_setup&.destroy
      community.reload
    end
  end
end
