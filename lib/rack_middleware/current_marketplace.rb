class CurrentMarketplace

  module Resolver

    module_function

    def resolve(host, app_domain)
      by_identifier = Community.find_by_identifier(identifiers(host, app_domain))

      if by_identifier
        by_identifier
      elsif Community.count == 1
        Community.first
      else
        nil
      end
    end

    def indentifiers(host, app_domain)
      app_domain_regexp = Regexp.escape(app_domain)
      ident_with_www = /^www\.(.+)\.#{app_domain}$/.match(req.host)
      ident_without_www = /^(.+)\.#{app_domain}$/.match(req.host)

      if ident_with_www
        {ident: ident_with_www[1]}
      elsif ident_without_www
        {ident: ident_without_www[1]}
      else
        {domain: host}
      end
    end

    def parse_community_identifiers_from_host(host, app_domain)
    end
  end

  def initialize(app, app_domain)
    @app = app
    @app_domain = app_domain
  end

  def call(env)
    req = Rack::Request.new(env)
    binding.pry
    env["marketplace"] = Resolver.resolve(req.host, @app_domain)

    @app.call(env)
  end
end
