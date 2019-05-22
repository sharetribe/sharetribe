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
      [:ident, :string, :mandatory],
      [:hold, :bool, :optional]
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
      [:no_communities, :bool, :mandatory]
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
         :hold,            # Marketplace plan is on hold
       ]],
      # Url
      [:url, :string, :optional],
      # Named route
      [:route_name, :symbol, :optional],
      [:status, :symbol, :mandatory],
      # detailed error message to be rendered
      [:message, :optional]
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

  ERROR_MESSAGES = {
    closed: {
      title: "Whoops, the %{community_name} marketplace no longer exists!",
      description: "Unfortunately the %{community_name} team has decided to close this platform, and it is no longer available.",
      cta: "Create your own online marketplace",
      cta_url: "https://www.sharetribe.com/?utm_source=%{marketplace_ident}.sharetribe.com&utm_medium=redirect&utm_campaign=qc-manual-redirect"
    },

    deleted: {
      title: "Whoops, the %{community_name} marketplace no longer exists!",
      description: "Unfortunately the %{community_name} team has decided to close this platform, and it is no longer available.",
      cta: "Create your own online marketplace",
      cta_url: "https://www.sharetribe.com/?utm_source=%{marketplace_ident}.sharetribe.com&utm_medium=redirect&utm_campaign=dl-manual-redirect"
    },

    hold: {
      title: "The %{community_name} marketplace is on hold.",
      description: "The %{community_name} team has decided to pause things and they will reopen this platform in the future",
      use_marketplace_logo: true
    }
  }

  module_function

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
  def redirect_target(reason:, request:, community:, paths:, configs:, message: nil)
    community = Maybe(community).map { |c| DataTypes.create_community(c) }.or_else(nil)
    request   = DataTypes.create_request(request)
    paths     = DataTypes.create_paths(paths)
    configs   = DataTypes.create_configs(configs)

    target =
      case reason
      when :no_marketplaces
        # Community not found, because there are no communities
        # -> Redirect to new community page
        paths[:new_community].merge(status: :found, protocol: request[:protocol])
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
      when :closed, :hold
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
        { url: domain_redirect_url(domain: community[:domain], request: request),
          status: :moved_permanently
        }
      when :use_ident, :www_ident
        # Community has a domain, but it's not in use.
        # -> Redirect to subdomain (ident)
        # OR
        # Accessed community with ident, including www
        # -> Redirect to ident without www
        { url: ident_redirect_url(ident: community[:ident], app_domain: configs[:app_domain], request: request),
          status: :moved_permanently
        }
      else
        raise ArgumentError.new("Unknown redirect reason: '#{reason}'")
      end

    HashUtils.compact(DataTypes::Target.call(target.merge(reason: reason, message: message)))
  end

  def domain_redirect_url(domain:, request:)
    host_redirect_url(host: domain, request: request)
  end

  def ident_redirect_url(ident:, app_domain:, request:)
    host_redirect_url(host: "#{ident}.#{app_domain}", request: request)
  end

  def host_redirect_url(host:, request:)
    "#{request[:protocol]}#{host}#{request[:port_string]}#{request[:fullpath]}"
  end

  # Returns a redirect reason or nil, if no redirect should be made
  #
  def redirect_reason(community:, host:, no_communities:, app_domain:)
    community = Maybe(community).map { |c| DataTypes.create_community(c) }.or_else(nil)

    if no_communities
      :no_marketplaces
    elsif community.nil? && !no_communities
      :not_found
    elsif community && community[:deleted]
      :deleted
    elsif community && community[:hold]
      :hold
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

  # This method is not side-effect free: It's aware of the global application
  # configs. You can use this method in a controller. This method will
  # call the block if redirect is needed.
  #
  # The method returns `true` if redirect is needed, so you can use it as a guard:
  #
  # ```
  # def index
  #   return if MarketplaceRouter.perform_redirect(community: @current_community, plan: @current_plan, request: request) { |target|
  #     url = target[:url] || send(target[:route_name], protocol: target[:protocol])
  #     redirect_to(url, status: target[:status])
  #   }
  # end
  # ```
  #
  def perform_redirect(community:, plan:, request:, &block)
    paths = {
      community_not_found: Maybe(APP_CONFIG).community_not_found_redirect.map { |url| {url: url} }.or_else({route_name: :community_not_found_path}),
      new_community: {route_name: :new_community_path}
    }

    configs = {
      app_domain: URLUtils.strip_port_from_host(APP_CONFIG.domain)
    }

    reason = request.env[:redirect_reason]

    if reason
      target = MarketplaceRouter.redirect_target(
        reason: reason,
        request: MarketplaceRouter.request_hash(request),
        community: MarketplaceRouter.community_hash(community, plan),
        paths: paths,
        configs: configs,
        message: MarketplaceRouter.make_error_message(community, reason)
      )

      block.call(target)
      true
    end
  end

  # Takes an ActionDispatch::Request or Rack::Request
  #
  # Returns a Hash in a form that MarketplaceRouter expects
  #
  def request_hash(request)
    {
      host: request.host,
      protocol: (request.respond_to?(:protocol) ? request.protocol : "#{request.scheme}://"),
      fullpath: request.fullpath,
      port_string: (request.respond_to?(:port_string) ? request.port_string : ":#{request.port}")
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
        closed: Maybe(plan)[:closed].or_else(false),
        hold: Maybe(plan)[:hold].or_else(false)
      }
    }.or_else(nil)
  end

  def make_error_message(community, reason)
    return nil unless ERROR_MESSAGES[reason] && community.is_a?(Community)

    ident = community.ident
    community_name =
      begin
        community.name(community.default_locale)
      rescue StandardError
        ident
      end

    var_map = {"community_name" => community_name, "marketplace_ident" => ident}
    message = {reason: reason}

    ERROR_MESSAGES[reason].each do |key, value|
      if key == :use_marketplace_logo
        message[key] = value
        message[:logo] = community.wide_logo.present? ? community.wide_logo.url(:header_highres) : nil
      else
        message[key] = value.gsub(/%\{(\w+)\}/){|var_name| var_map[Regexp.last_match[1]] }
      end
    end
    message
  end
end
