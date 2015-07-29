module MarketplaceRedirectUtils

  module_function

  def needs_redirect(host:,
                     headers:,
                     is_ssl:,
                     always_use_ssl:,
                     protocol:,
                     fullpath:,
                     port_string:,
                     redirect_to_domain:,
                     community_not_found_url:,
                     community_deleted:,
                     no_communities:,
                     found_community:,
                     new_community_path:,
                     community_domain: nil,
                     &block)

    new_protocol_opt = always_use_ssl ? "https" : (protocol == "http://" ? "http" : "https")
    new_protocol_url = always_use_ssl ? "https://" : (protocol == "http://" ? "http://" : "https://")
    protocol_needs_redirect = protocol != new_protocol_url
    new_status = protocol_needs_redirect ? :moved_permanently : nil

    if !found_community
      if no_communities
        block.call(new_community_path.merge(status: (new_status || :found), protocol: new_protocol_opt))
      else
        block.call(community_not_found_url.merge(status: (new_status || :found), protocol: new_protocol_opt))
      end
    elsif community_deleted
      block.call(community_not_found_url.merge(status: (new_status || :moved_permanently), protocol: new_protocol_opt))
    elsif community_domain.present? && redirect_to_domain && host != community_domain
      block.call({url: "#{new_protocol_url}#{community_domain}#{port_string}#{fullpath}", status: (new_status || :moved_permanently)})
    elsif protocol_needs_redirect
      block.call({url: "#{new_protocol_url}#{host}#{port_string}#{fullpath}", status: new_status})
    end

  end

end
