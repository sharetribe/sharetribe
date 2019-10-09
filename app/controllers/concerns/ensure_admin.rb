module EnsureAdmin
  extend ActiveSupport::Concern

  private

  def ensure_is_admin
    unless @is_current_community_admin
      flash[:error] = t("layouts.notifications.only_kassi_administrators_can_access_this_area")
      if logged_in?
        redirect_to search_path and return
      else
        session[:return_to] = request.fullpath
        redirect_to login_path and return
      end
    end
  end

  def ensure_is_superadmin
    unless Maybe(@current_user).is_admin?.or_else(false)
      flash[:error] = t("layouts.notifications.only_kassi_administrators_can_access_this_area")
      redirect_to search_path and return
    end
  end
end
