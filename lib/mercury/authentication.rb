module Mercury
  module Authentication

    def can_edit?
      @current_user = current_person
      @current_community = ApplicationController.default_community_fetch_strategy(request.host)
      @current_user && @current_community && @current_user.has_admin_rights_in?(@current_community)
    end

  end
end
