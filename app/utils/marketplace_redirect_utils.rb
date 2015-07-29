module MarketplaceRedirectUtils

  module_function

  def needs_redirect(host:,
                     protocol:,
                     fullpath:,
                     domain_ready:,
                     community_domain: nil,
                     &block)
    if community_domain.present? && domain_ready && host != community_domain
      block.call("#{protocol}#{community_domain}#{fullpath}", :moved_permanently)
    end

  end

end
