# Appends current marketplace info to env.
#
# Note: Is safe to run, even if there's no current_marketplace
class MarketplaceLookup
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    app_domain = ::URLUtils.strip_port_from_host(::APP_CONFIG.domain)
    host = ::URLUtils.strip_port_from_host(env['HTTP_HOST'])
    marketplace = ::CurrentMarketplaceResolver.resolve_from_host(host, app_domain)

    plan =
      if marketplace
        ::PlanService::API::Api.plans.get_current(community_id: marketplace.id).data
      end

    no_marketplaces =
      if marketplace
        false
      else
        Community.count == 0
      end

    redirect_reason = ::MarketplaceRouter.redirect_reason(
      community: ::MarketplaceRouter.community_hash(marketplace, plan),
      host: request.host,
      no_communities: no_marketplaces,
      app_domain: app_domain)

    @app.call(env.merge!(
                current_marketplace: marketplace,
                current_plan: plan,
                redirect_reason: redirect_reason))
  end
end
