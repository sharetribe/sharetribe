module MarketplaceRedirectUtils

  module_function

  def needs_redirect(request:,
                     community:,
                     paths:,
                     configs:,
                     other:,
                     &block)

    new_protocol_opt = configs[:always_use_ssl] ? "https" : (request[:protocol] == "http://" ? "http" : "https")
    new_protocol_url = configs[:always_use_ssl] ? "https://" : (request[:protocol] == "http://" ? "http://" : "https://")
    protocol_needs_redirect = request[:protocol] != new_protocol_url
    new_status = protocol_needs_redirect ? :moved_permanently : nil

    if community.nil?
      if other[:no_communities]
        block.call(paths[:new_community].merge(status: (new_status || :found), protocol: new_protocol_opt))
      else
        block.call(paths[:community_not_found].merge(status: (new_status || :found), protocol: new_protocol_opt))
      end
    elsif community[:community_deleted]
      block.call(paths[:community_not_found].merge(status: (new_status || :moved_permanently), protocol: new_protocol_opt))
    elsif community[:community_domain].present? && community[:redirect_to_domain] && request[:host] != community[:community_domain]
      block.call({url: "#{new_protocol_url}#{community[:community_domain]}#{request[:port_string]}#{request[:fullpath]}", status: (new_status || :moved_permanently)})
    elsif protocol_needs_redirect
      block.call({url: "#{new_protocol_url}#{request[:host]}#{request[:port_string]}#{request[:fullpath]}", status: new_status})
    end

  end

end
