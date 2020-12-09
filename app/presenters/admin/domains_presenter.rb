class Admin::DomainsPresenter

  private

  attr_reader :service

  public

  delegate :community,
           :white_label?,
           :use_domain?,
           :domain_possible?,
           :ident,
           :domain,
           to: :service, prefix: false

  def initialize(service:)
    @service = service
  end

  def domain_disabled?
    !white_label?
  end

  def domain_used?
    white_label? && use_domain?
  end

  def domain_address
    domain_used? ? "https://#{domain}" : ident_address
  end

  def ident_address
    "https://#{ident}.sharetribe.com"
  end

  def domain_setup_state
    community.domain_setup&.state
  end

  def critical_error?
    DomainSetup.critical_error?
  end

  def domain_checked
    d = community.domain_setup&.domain
    if d&.match(/xn--/)
      SimpleIDN.to_unicode(d)
    else
      d
    end
  end

  def domain_checked_for_redirect
    DomainSetup.www_alt_name(domain_checked)
  end
end
