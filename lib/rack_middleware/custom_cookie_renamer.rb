class CustomCookieRenamer
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["HTTP_COOKIE"] && !(env["HTTP_COOKIE"] =~ /\b#{APP_CONFIG.cookie_session_key}/)
      env["HTTP_COOKIE"].sub!(/\b#{APP_CONFIG.session_key}=/, "#{APP_CONFIG.cookie_session_key}=")
    end

    @app.call(env)
  end

end
