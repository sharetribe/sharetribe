# Custom Domain Cookie

# Credits from this code go to Nader (http://stackoverflow.com/questions/4060333/what-does-rails-3-session-store-domain-all-really-do)


# Set the cookie domain to the custom domain if it's present
class CustomDomainCookie
  def initialize(app, default_domain)
    @app = app
    @default_domain = default_domain.split(':').first
  end

  def call(env)
    # puts "NOW CALLED #{env.inspect}"
    
    if env["HTTP_HOST"]
      host = env["HTTP_HOST"].split(':').first 
    else
      host = nil
    end
    env["rack.session.options"][:domain] = custom_domain?(host) ? ".#{host}" : "#{@default_domain}"
    resp = @app.call(env)
    #puts "APP RETURNED #{resp.inspect}"
    if resp.class == Array && resp[2] && resp[2] != nil
      # puts "RETURN OK"
    else
      puts "NIL BODY ALERT! \nRESP IS: #{resp.inspect} \nREQ ENV WAS: #{env.inspect}"
    end
    return resp
  end

  def custom_domain?(host)
    return false if host.nil?
    host !~ /#{@default_domain.sub(/^\./, '')}/i
  end
end