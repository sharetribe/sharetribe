module MarketplaceRouter
  module DataTypes

    LIKE_HASH = ->(v) {
      return if v.nil?

      unless v.respond_to?(:[])
        {code: :must_be_hash_like, msg: "Value must be like hash (i.e. responds to :[])"}
      end
    }

    Request = EntityUtils.define_builder(
      [:host, :string, :mandatory],
      [:protocol, :string, one_of: ["http://", "https://"]],
      [:fullpath, :string, :mandatory],
      [:port_string, :string, :optional, default: ""],
      [:headers, :mandatory, validate_with: LIKE_HASH]
    )

    Community = EntityUtils.define_builder(
      [:use_domain, :bool, :mandatory],
      [:deleted, :bool, :mandatory],
      [:closed, :bool, :mandatory],
      [:domain, :string, :optional],
      [:domain_verification_file, :optional],
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
      [:always_use_ssl, :bool, :mandatory],
      [:app_domain, :string, :mandatory]
    )

    Other = EntityUtils.define_builder(
      [:no_communities, :bool, :mandatory],
      [:community_search_status, one_of: [:found, :not_found, :skipped]]
    )

    # Target can be either URL or named route.
    # If URL, protocol and route_name are not needed
    # If named route, URL is not needed
    # Status should be included always
    Target = EntityUtils.define_builder(
      # Url
      [:url, :string, :optional],

      # Named route
      [:protocol, :string, :optional],
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
    is_domain_verification = Maybe(community)[:domain_verification_file].map { |dv_file| request[:fullpath] == "/#{dv_file}" }.or_else(false)
    new_protocol = protocol(request: request, community: community, configs: configs, is_domain_verification: is_domain_verification)
    protocol_needs_redirect = request[:protocol] != "#{new_protocol}://"

    target = redirect_target(
      request:                 DataTypes.create_request(request),
      community:               Maybe(community).map { |c| DataTypes.create_community(c) }.or_else(nil),
      paths:                   DataTypes.create_paths(paths),
      configs:                 DataTypes.create_configs(configs),
      other:                   DataTypes.create_other(other),
      protocol:                new_protocol,
      protocol_needs_redirect: protocol_needs_redirect,
      is_domain_verification:  is_domain_verification
    )

    block.call(target) if target
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
  # rubocop:disable ParameterLists
  def redirect_target(request:, community:, paths:, configs:, other:, protocol:, protocol_needs_redirect:, is_domain_verification:)
    target =
      if other[:community_search_status] == :not_found && other[:no_communities]
        # Community not found, because there are no communities
        # -> Redirect to new community page
        paths[:new_community].merge(status: :found, protocol: protocol)

      elsif other[:community_search_status] == :not_found && !other[:no_communities]
        # Community not found
        # -> Redirect to not found
        Maybe(paths[:community_not_found])[:url].map { |u|
          URLUtils.build_url(u, {utm_source: request[:host], utm_medium: "redirect", utm_campaign: "na-auto-redirect"})
        }.map { |u|
          {url: u, status: :found, protocol: protocol}
        }.or_else {
          paths[:community_not_found].merge(status: :found, protocol: protocol)
        }

      elsif community && community[:deleted]
        # Community deleted
        # -> Redirect to not found
        Maybe(paths[:community_not_found])[:url].map { |u|
          URLUtils.build_url(u, {utm_source: request[:host], utm_medium: "redirect", utm_campaign: "dl-auto-redirect"})
        }.map { |u|
          {url: u, status: :moved_permanently, protocol: protocol}
        }.or_else {
          paths[:community_not_found].merge(status: :moved_permanently, protocol: protocol)
        }

      elsif community && community[:closed]
        # Community closed
        # -> Redirect to not found
        Maybe(paths[:community_not_found])[:url].map { |u|
          URLUtils.build_url(u, {utm_source: request[:host], utm_medium: "redirect", utm_campaign: "qc-auto-redirect"})
        }.map { |u|
          {url: u, status: :moved_permanently, protocol: protocol}
        }.or_else {
          paths[:community_not_found].merge(status: :moved_permanently, protocol: protocol)
        }

      elsif community && community[:domain].present? && community[:use_domain] && request[:host] != community[:domain]
        # Community has domain ready, should use it
        # -> Redirect to community domain
        {url: "#{protocol}://#{community[:domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}

      elsif community && community[:domain].present? && !community[:use_domain] && request[:host] == community[:domain] && !is_domain_verification
        {url: "#{protocol}://#{community[:ident]}.#{configs[:app_domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}

      elsif community && request[:host] == "www.#{community[:ident]}.#{configs[:app_domain]}"
        # Accessed community with ident, including www
        # -> Redirect to ident without www
        {url: "#{protocol}://#{community[:ident]}.#{configs[:app_domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}

      elsif protocol_needs_redirect
        # Needs protocol redirect (to https)
        # -> Redirect to https
        {url: "#{protocol}://#{request[:host]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}
            end

    # If protocol redirect is needed, the status is always :moved_permanently
    Maybe(target)
      .map { |t| t.merge(status: protocol_needs_redirect ? :moved_permanently : t[:status]) }
      .map { |t| HashUtils.compact(DataTypes::Target.call(t)) }
      .or_else(nil)
  end
  # rubocop:enable ParameterLists

  def protocol(request:, community:, configs:, is_domain_verification:)
    if should_use_https?(request: request, community: community, configs: configs, is_domain_verification: is_domain_verification)
      "https"
    else
      request[:protocol] == "http://" ? "http" : "https"
    end
  end

  def should_use_https?(request:, configs:, community:, is_domain_verification:)
    from_proxy = (request[:headers]["HTTP_VIA"] && request[:headers]["HTTP_VIA"].include?("sharetribe_proxy"))
    robots = request[:fullpath] == "/robots.txt"

    configs[:always_use_ssl] && !from_proxy && !robots && !is_domain_verification
  end

end
