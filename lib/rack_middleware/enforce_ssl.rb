class EnforceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    if ::APP_CONFIG.always_use_ssl.to_s == "true" && env["HTTPS"] == "off" # always_use_ssl can be string if it comes from ENV
      req = ::Rack::Request.new(env)
      port_s = req.port ? ":#{req.port}" : ""
      redirect("https://#{req.host}#{port_s}#{req.fullpath}")
    else
      @app.call(env)
    end
  end

  private

  def redirect(location)
    [301, {'Location' => location, 'Content-Type' => 'text/html'}, ["Moved permanently"]]
  end
end
