module MarketplaceRouter
  module DataTypes

    Request = EntityUtils.define_builder(
      [:host, :string, :mandatory],
      [:protocol, :string, one_of: ["http://", "https://"]],
      [:fullpath, :string, :mandatory],
      [:port_string, :string, :optional, default: ""]
    )

    Community = EntityUtils.define_builder(
      [:use_domain, :bool, :mandatory],
      [:deleted, :bool, :mandatory],
      [:closed, :bool, :mandatory],
      [:domain, :string, :optional],
      [:ident, :string, :mandatory]
    )

    Path = EntityUtils.define_builder(
      [:url, :string, :optional],
      [:route_name, :symbol, :optional]
    )

    Paths = EntityUtils.define_builder(
      [:community_not_found, :mandatory, entity: Path],
      [:new_community, :mandatory, entity: Path]
    )

    Configs = EntityUtils.define_builder(
      [:app_domain, :string, :mandatory]
    )

    Other = EntityUtils.define_builder(
      [:no_communities, :bool, :mandatory],
      [:community_search_status, one_of: [:found, :not_found, :skipped]]
    )

    # Target can be either URL or named route.
    # If URL, route_name are not needed
    # If named route, URL is not needed
    # Status should be included always
    Target = EntityUtils.define_builder(
      # Reason
      [:reason, :symbol, one_of: [
         :use_domain,      # Marketplace has a custom domain in use. Redirect to that domain.
         :use_ident,       # Marketplace has a custom domain but it's not in use. Redirect to subdomain.
         :deleted,         # Marketplace has been deleted
         :closed,          # Marketplace has been closed
         :not_found,       # Marketplace not found, but some marketplaces do exist
         :no_marketplaces, # There are no marketplaces. Redirect to new marketplace page
         :www_ident,       # Accessed marketplace with WWW and subdomain, e.g. www.mymarketplace.sharetribe.com
       ]],

      # Url
      [:url, :string, :optional],

      # Named route
      [:route_name, :symbol, :optional],

      [:status, :symbol, :mandatory]
    )

    module_function

    def create_request(opts)
      Request.call(opts)
    end

    def create_community(opts)
      Community.call(opts)
    end

    def create_paths(opts)
      Paths.call(opts)
    end

    def create_configs(opts)
      Configs.call(opts)
    end

    def create_other(opts)
      Other.call(opts)
    end
  end

  module_function

  def needs_redirect(request:, community:, paths:, configs:, other:, &block)
    reason = redirect_reason(
      host: request[:host],
      community: community,
      app_domain: configs[:app_domain],
      no_communities: other[:no_communities],
      community_search_status: other[:community_search_status])

    if reason
      target = redirect_target(
        reason:                  reason,
        request:                 DataTypes.create_request(request),
        community:               Maybe(community).map { |c| DataTypes.create_community(c) }.or_else(nil),
        paths:                   DataTypes.create_paths(paths),
        configs:                 DataTypes.create_configs(configs),
        protocol:                request[:protocol]
      )

      block.call(target)
    end
  end

  # private

  # The main "router function"
  #
  # Returns a hash, which contains either a url or named route
  #
  # Example, return hash with url:
  #
  # { url: "https://marketplace.sharetribe.com/listings", status :found }
  #
  # Example, return hash with named route:
  #
  # { route_name: :new_community, status: :moved_permanently, protocol: "http"}
  #
  def redirect_target(reason:, request:, community:, paths:, configs:, protocol:)
    target =
      case reason
      when :no_marketplaces
        # Community not found, because there are no communities
        # -> Redirect to new community page
        paths[:new_community].merge(status: :found, protocol: protocol)
      when :not_found
        # Community not found
        # -> Redirect to not found
        Maybe(paths[:community_not_found])[:url].map { |u|
          URLUtils.build_url(u, {utm_source: request[:host], utm_medium: "redirect", utm_campaign: "na-auto-redirect"})
        }.map { |u|
          {url: u, status: :found}
        }.or_else {
          paths[:community_not_found].merge(status: :found)
        }
      when :deleted
        # Community deleted
        # -> Redirect to not found
        Maybe(paths[:community_not_found])[:url].map { |u|
          URLUtils.build_url(u, {utm_source: request[:host], utm_medium: "redirect", utm_campaign: "dl-auto-redirect"})
        }.map { |u|
          {url: u, status: :moved_permanently}
        }.or_else {
          paths[:community_not_found].merge(status: :moved_permanently)
        }
      when :closed
        # Community closed
        # -> Redirect to not found
        Maybe(paths[:community_not_found])[:url].map { |u|
          URLUtils.build_url(u, {utm_source: request[:host], utm_medium: "redirect", utm_campaign: "qc-auto-redirect"})
        }.map { |u|
          {url: u, status: :moved_permanently}
        }.or_else {
          paths[:community_not_found].merge(status: :moved_permanently)
        }
      when :use_domain
        # Community has domain ready, should use it
        # -> Redirect to community domain
        {url: "#{protocol}#{community[:domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}
      when :use_ident
        # Community has a domain, but it's not in use.
        # -> Redirect to subdomain (ident)
        {url: "#{protocol}#{community[:ident]}.#{configs[:app_domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}
      when :www_ident
        # Accessed community with ident, including www
        # -> Redirect to ident without www
        {url: "#{protocol}#{community[:ident]}.#{configs[:app_domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}
      else
        raise ArgumentError.new("Unknown redirect reason: '#{reason}'")
      end

    HashUtils.compact(DataTypes::Target.call(target.merge(reason: reason)))
  end

  def redirect_reason(community:, host:, community_search_status:, no_communities:, app_domain:)
    if community_search_status == :not_found && no_communities
      :no_marketplaces
    elsif community_search_status == :not_found && !no_communities
      :not_found
    elsif community && community[:deleted]
      :deleted
    elsif community && community[:closed]
      :closed
    elsif community && community[:domain].present? && community[:use_domain] && host != community[:domain]
      :use_domain
    elsif community && community[:domain].present? && !community[:use_domain] && host == community[:domain]
      :use_ident
    elsif community && host == "www.#{community[:ident]}.#{app_domain}"
      :www_ident
    end
  end

  # Takes a Request
  #
  # Returns a Hash in a form that MarketplaceRouter expects
  #
  def request_hash(request)
    {
      host: request.host,
      protocol: request.protocol,
      fullpath: request.fullpath,
      port_string: request.port_string,
    }
  end

  # Takes a Community model and Plan entity.
  #
  # Returns a Hash in a form that MarketplaceRouter expects
  #
  def community_hash(community, plan)
    Maybe(community).map { |c|
      {
        ident: c.ident,
        domain: c.domain,
        deleted: c.deleted?,
        use_domain: c.use_domain?,
        closed: Maybe(plan)[:closed].or_else(false)
      }
    }.or_else(nil)
  end
end
