class EnforceSsl
  def initialize(app)
    @app = app
  end

  def call(env)
    req = ::Rack::Request.new(env)
    if ::APP_CONFIG.always_use_ssl.to_s == "true" && !req.ssl? # always_use_ssl can be string if it comes from ENV
      domain = ::APP_CONFIG.domain

      # If request is for something.IDENT.domain, strip "something" before redirecting
      # This avoids issue with wildcard SSL certificate covering *.domain
      matches = /^(.*)\.(([^\.]+)\.#{domain})$/.match(req.host)
      redirect_host = if matches
                        matches[2]
                      else
                        req.host
                      end

      path = req.fullpath == "/" ? "" : req.fullpath
      redirect("https://#{redirect_host}#{path}")
    else
      @app.call(env)
    end
  end

  private

  def redirect(location)
    [301, {'Location' => location, 'Content-Type' => 'text/html'}, ["Moved permanently"]]
  end
end
