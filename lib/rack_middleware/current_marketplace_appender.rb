# Appends current marketplace info to env.
#
# Note: Is safe to run, even if there's no current_marketplace
class CurrentMarketplaceAppender
  def initialize(app)
    @app = app
  end

  def call(env)
    app_domain = ::URLUtils.strip_port_from_host(::APP_CONFIG.domain)
    host = ::URLUtils.strip_port_from_host(env['HTTP_HOST'])
    marketplace = ::CurrentMarketplaceResolver.resolve_from_host(host, app_domain)

    plan =
      if marketplace
        PlanService::API::Api.plans.get_current(community_id: marketplace.id).data
      end

    @app.call(env.merge!(current_marketplace: marketplace, current_plan: plan))
  end
end
