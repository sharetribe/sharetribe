class Admin::DomainsPresenter

  private

  attr_reader :service

  public

  delegate :community, :white_label?, :use_domain?, :ident, :domain, to: :service, prefix: false

  def initialize(service:)
    @service = service
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
end
