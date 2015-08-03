module Mercury
  module Authentication

    def can_edit?
      @current_user = current_person
      @current_community = ApplicationController.find_community(community_identifiers)
      @current_user && @current_community && @current_user.has_admin_rights_in?(@current_community)
    end

    def community_identifiers
      app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
      ApplicationController.parse_community_identifiers_from_host(request.host, app_domain)
    end

  end
end
