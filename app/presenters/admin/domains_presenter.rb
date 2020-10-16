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
    domain_used? ? "https://#{domain}" : "https://#{ident}.sharetribe.com"
  end

  def feature_domain?
    FeatureFlagHelper.feature_enabled?(:domain)
  end

  def domain_setup_state
    community.domain_setup&.state
  end

  def critical_error?
    DomainSetup.critical_error?
  end

  def domain_checked
    d = community.domain_setup&.domain
    if d && d.match(/xn--/)
      SimpleIDN.to_unicode(d)
    else
      d
    end
  end

  def domain_checked_for_redirect
    if domain_checked.starts_with?("www.")
      domain_checked[4..-1]
    else
      "www.#{domain_checked}"
    end
  end
end
