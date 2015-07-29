module MarketplaceRedirectUtils

  module_function

  def needs_redirect(host:,
                     protocol:,
                     fullpath:,
                     port_string:,
                     redirect_to_domain:,
                     community_not_found_url:,
                     community_deleted:,
                     community_domain: nil,
                     &block)

    if community_deleted
      block.call(community_not_found_url, :moved_permanently)
    elsif community_domain.present? && redirect_to_domain && host != community_domain
      block.call("#{protocol}#{community_domain}#{port_string}#{fullpath}", :moved_permanently)
    end

  end

end
