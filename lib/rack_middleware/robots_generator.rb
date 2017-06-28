# Credits to Avand: http://avandamiri.com/2011/10/11/serving-different-robots-using-rack.html

class RobotsGenerator

  CONTENT_TYPE = { "Content-Type" => "text/plain" }

  def self.call(env)
    community = community(env)
    reason = redirect_reason(env)
    req = Rack::Request.new(env)

    target = redirect_target(community, reason, req)
    return target unless target.nil?

    begin

      # Disallow indexing from other than production environments
      body =
        if Rails.env.production?
          index_content(req)
        else
          no_index_content()
        end

      return [200, CONTENT_TYPE, [body]]
    rescue Errno::ENOENT
      return [404, CONTENT_TYPE, ['# A robots.txt is not configured']]
    end
  end

  def self.redirect_target(community, reason, request)
    app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
    request_hash = MarketplaceRouter.request_hash(request)

    case reason
    when :use_domain
      redirect_to(
        MarketplaceRouter.domain_redirect_url(
          domain: community.domain,
          request: request_hash))
    when :use_ident, :www_ident
      redirect_to(
        MarketplaceRouter.ident_redirect_url(
          ident: community.ident,
          app_domain: app_domain,
          request: request_hash))
    when :deleted, :closed, :not_found, :no_marketplaces
      not_found
    end

  end

  def self.community(env)
    env[:current_marketplace]
  end

  def self.redirect_reason(env)
    env[:redirect_reason]
  end

  def self.not_found
    [404, CONTENT_TYPE, ['Not Found']]
  end

  def self.redirect_to(location)
    [301, {'Location' => location}.merge(CONTENT_TYPE), ['Moved Permanently']]
  end

  def self.index_content(req)
    [
      "User-agent: *",
      "Disallow: /*auth$",
      "Crawl-Delay: 5",
      "Sitemap: #{req.scheme}://#{req.host_with_port}/sitemap.xml.gz"
    ].join("\n")
  end

  def self.no_index_content
    [
      "User-agent: *",
      "Disallow: /"
    ].join("\n")
  end
end
