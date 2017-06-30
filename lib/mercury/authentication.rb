module Mercury
  module Authentication

    def can_edit?
      @current_user = current_person
      @current_community = CurrentMarketplaceResolver.resolve_from_host(request.host, URLUtils.strip_port_from_host(APP_CONFIG.domain))
      @current_user && @current_community && @current_user.has_admin_rights?(@current_community)
    end
  end
end
