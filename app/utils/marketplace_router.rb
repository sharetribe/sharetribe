module MarketplaceRouter

  module_function

  def needs_redirect(request:, community:, paths:, configs:, other:, &block)
    new_protocol = protocol(request: request, community: community, configs: configs)
    protocol_needs_redirect = request[:protocol] != "#{new_protocol}://"

    target = redirect_target(
      request: request,
      community: community,
      paths: paths,
      configs: configs,
      other: other,
      protocol: new_protocol,
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
      if other[:community_search_status] == :not_found && other[:no_communities]
        # Community not found, because there are no communities
        # -> Redirect to new community page
        paths[:new_community].merge(status: :found, protocol: protocol)

      elsif other[:community_search_status] == :not_found && !other[:no_communities]
        # Community not found
        # -> Redirect to not found
        paths[:community_not_found].merge(status: :found, protocol: protocol)

      elsif community && community[:deleted]
        # Community deleted
        # -> Redirect to not found
        paths[:community_not_found].merge(status: :moved_permanently, protocol: protocol)

      elsif community && community[:domain].present? && community[:redirect_to_domain] && request[:host] != community[:domain]
        # Community has domain ready, should use it
        # -> Redirect to community domain
        {url: "#{protocol}://#{community[:domain]}#{request[:port_string]}#{request[:fullpath]}", status: :moved_permanently}

      elsif community && request[:host] == "www.#{community[:ident]}.#{configs[:app_domain]}"
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

  def protocol(request:, community:, configs:)
    if should_use_https?(request: request, community: community, configs: configs)
      "https"
    else
      request[:protocol] == "http://" ? "http" : "https"
    end
  end

  def should_use_https?(request:, configs:, community:)
    from_proxy = (request[:headers]["HTTP_VIA"] && request[:headers]["HTTP_VIA"].include?("sharetribe_proxy"))
    robots = request[:fullpath] == "/robots.txt"
    domain_verification = Maybe(community)[:domain_verification_file].map { |dv_file| request[:fullpath] == "/#{dv_file}" }.or_else(false)

    configs[:always_use_ssl] && !from_proxy && !robots && !domain_verification
  end

end
