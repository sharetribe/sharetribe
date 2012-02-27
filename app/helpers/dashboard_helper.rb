module DashboardHelper
  
  def get_url_for(community)
    "http://#{community.domain}.#{request.domain}/#{I18n.locale}"
  end
  
end
