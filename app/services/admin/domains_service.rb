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
end
