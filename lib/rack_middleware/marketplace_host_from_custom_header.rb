# Updates the request host name, based on custom header. Can be used to route
# traffic to correct marketplace in cases where Host: header can not be
# preserved for some reason.
class MarketplaceHostFromCustomHeader
  def initialize(app)
    @app = app
  end

  def call(env)
    custom_host = env['HTTP_ST_GO_HOST']
    custom_host_auth = env['HTTP_ST_GO_PROXY_AUTH']

    if custom_host && custom_host_auth == ::APP_CONFIG.proxy_auth_secret
      @app.call(env.merge!(
                  'HTTP_HOST' => custom_host,
                  'SERVER_NAME' => custom_host))
    else
      @app.call(env)
    end
  end
end
