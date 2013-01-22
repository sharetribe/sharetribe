class CommunityDomain  
  def self.matches?(request)
    ! APP_CONFIG.domain.include?(request.domain) || 
      (request.subdomain != 'www' && 
       request.subdomain != ''    &&
       request.subdomain != 'dashboardtranslate')
  end  
end