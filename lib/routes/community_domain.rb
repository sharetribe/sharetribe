class CommunityDomain
  def self.matches?(request)
    ! APP_CONFIG.domain.include?(request.domain) ||
    ! APP_CONFIG.dashboard_subdomains.include?(request.subdomain)
  end
end
