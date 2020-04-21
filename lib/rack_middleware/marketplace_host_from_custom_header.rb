# Updates the request host name, based on custom header. Can be used to route
# traffic to correct marketplace in cases where Host: header can not be
# preserved for some reason.
class MarketplaceHostFromCustomHeader
  def initialize(app)
    @app = app
  end

  def call(env)
    custom_host = env['HTTP_GO_CUSTOM_HOST']
    proxy_auth = env['HTTP_GO_PROXY_AUTH']

    if ::APP_CONFIG.use_custom_host_header.to_s.casecmp("true") == 0 &&
       custom_host &&
       proxy_auth == ::APP_CONFIG.proxy_auth_secret

      port = ::URLUtils.port_from_host(env['HTTP_HOST']) || env['SERVER_PORT']
      new_host = "#{custom_host}:#{port}"

      @app.call(env.merge!(
                  'HTTP_HOST' => new_host,
                  'SERVER_NAME' => custom_host))
    else
      @app.call(env)
    end
  end
end
