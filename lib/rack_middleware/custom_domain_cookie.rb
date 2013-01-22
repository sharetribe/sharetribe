# Custom Domain Cookie

# Credits from this code go to Nader (http://stackoverflow.com/questions/4060333/what-does-rails-3-session-store-domain-all-really-do)


# Set the cookie domain to the custom domain if it's present
class CustomDomainCookie
  def initialize(app, default_domain)
    @app = app
    @default_domain = default_domain.split(':').first
  end

  def call(env)
    host = env["HTTP_HOST"].split(':').first
    env["rack.session.options"][:domain] = custom_domain?(host) ? ".#{host}" : "#{@default_domain}"
    @app.call(env)
  end

  def custom_domain?(host)
    host !~ /#{@default_domain.sub(/^\./, '')}/i
  end
end