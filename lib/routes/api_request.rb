class ApiRequest  
  def self.matches?(request)  
    (request.subdomain.present? && request.subdomain == 'api') || request.format == "atom"
  end  
end