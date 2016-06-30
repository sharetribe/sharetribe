class EnforceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    req = ::Rack::Request.new(env)
    if ::APP_CONFIG.always_use_ssl.to_s == "true" && !req.ssl? # always_use_ssl can be string if it comes from ENV
      redirect("https://#{req.host}#{req.fullpath}")
    else
      @app.call(env)
    end
  end

  private

  def redirect(location)
    [301, {'Location' => location, 'Content-Type' => 'text/html'}, ["Moved permanently"]]
  end
end
