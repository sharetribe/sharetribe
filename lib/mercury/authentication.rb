module Mercury
  module Authentication

    def can_edit?
      logger.info "Authentication check"
      logger.info "Session: #{session.inspect}"
      @current_user = current_person
      @current_community = Community.find_by_domain(request.subdomain) || Community.find_by_domain(request.host)
      logger.info "Current user: #{@current_user.inspect}"
      logger.info "Current community: #{@current_community.inspect}"
      @current_user && @current_community && @current_user.has_admin_rights_in?(@current_community)
    end

  end
end
