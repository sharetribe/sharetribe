class CommunityDomain
  def self.matches?(request)
    ! APP_CONFIG.domain.include?(request.host)
  end
end
