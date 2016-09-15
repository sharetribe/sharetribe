#
# Defines the redirect reason for a marketplace.
#
# Please note! This middleware does NOT DO the actual
# redirect. It's left to controllers and middleware to define how and
# where to redirect.
#
class MarketplaceRedirectReason
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    marketplace, plan, no_marketplaces = env.values_at(:current_marketplace, :current_plan, :no_marketplaces)

    redirect_reason = ::MarketplaceRouter.redirect_reason(
      community: ::MarketplaceRouter.community_hash(marketplace, plan),
      host: request.host,
      community_search_status: marketplace.nil? ? :not_found : :found,
      no_communities: no_marketplaces,
      app_domain: ::URLUtils.strip_port_from_host(APP_CONFIG.domain)
    )

    @app.call(env.merge!(redirect_reason: redirect_reason))
  end
end
