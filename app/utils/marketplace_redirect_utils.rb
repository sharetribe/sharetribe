module MarketplaceRedirectUtils

  module_function

  def needs_redirect(request:, community:, paths:, configs:, other:, &block)

    use_https = should_use_https?(request: request, community: community, configs: configs)

    protocol = use_https ? "https" : (request[:protocol] == "http://" ? "http" : "https")
    protocol_needs_redirect = request[:protocol] != "#{protocol}://"

    target = redirect_target(
      request: request,
      community: community,
      paths: paths,
      configs: configs,
      other: other,
      protocol: protocol,
      protocol_needs_redirect: protocol_needs_redirect
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
  def redirect_target(request:, community:, paths:, configs:, other:, protocol:, protocol_needs_redirect:)
    target =
      if community.nil? && other[:no_communities]
        # Community not found, because there are no communities
        # -> Redirect to new community page
        paths[:new_community].merge(status: :found, protocol: protocol)

      elsif community.nil? && !other[:no_communities]
        # Community not found
        # -> Redirect to not found
        paths[:community_not_found].merge(status: :found, protocol: protocol)

      elsif community[:deleted]
        # Community deleted
        # -> Redirect to not found
        paths[:community_not_found].merge(status: :moved_permanently, protocol: protocol)

      elsif community[:domain].present? && community[:redirect_to_domain] && request[:host] != community[:domain]
        # Community has domain ready, should use it
        # -> Redirect to community domain
        {url: "#{protocol}://#{community[:domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}

      elsif request[:host] == "www.#{community[:ident]}.#{configs[:app_domain]}"
        # Accessed community with ident, including www
        # -> Redirect to ident without www
        {url: "#{protocol}://#{community[:ident]}.#{configs[:app_domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}

      elsif protocol_needs_redirect
        # Needs protocol redirect (to https)
        # -> Redirect to https
        {url: "#{protocol}://#{request[:host]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}
      else
        # no need to redirect
        nil
      end

    # If protocol redirect is needed, the status is always :moved_permanently
    Maybe(target)
      .map { |t| t.merge(status: protocol_needs_redirect ? :moved_permanently : t[:status]) }
      .or_else(nil)
  end

  def should_use_https?(request:, configs:, community:)
    from_proxy = (request[:headers]["HTTP_VIA"] && request[:headers]["HTTP_VIA"].include?("sharetribe_proxy"))
    robots = request[:fullpath] == "/robots.txt"
    domain_verification = Maybe(community)[:domain_verification_file].map { |dv_file| request[:fullpath] == "/#{dv_file}" }.or_else(false)

    configs[:always_use_ssl] && !from_proxy && !robots && !domain_verification
  end

end
