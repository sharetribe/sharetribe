class CommunityDomain  
  def self.matches?(request)
    request.domain != APP_CONFIG.domain || 
      (request.subdomain != 'www' && 
       request.subdomain != ''    &&
       request.subdomain != 'dashboardtranslate')
  end  
end