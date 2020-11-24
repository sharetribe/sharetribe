class HealthCheck
  def initialize(app)
    @app = app
  end

  def call(env)
    req = ::Rack::Request.new(env)

    if req.fullpath == "/_health"
      [200, {'Content-Type' => 'text/plain'}, ["OK"]]
    else
      @app.call(env)
    end
  end
end
