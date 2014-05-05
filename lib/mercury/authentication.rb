module Mercury
  module Authentication

    def can_edit?
      @current_user = current_person
      @current_community = Community.find_by_domain(request.host)
      @current_user && @current_community && @current_user.has_admin_rights_in?(@current_community)
    end

  end
end
