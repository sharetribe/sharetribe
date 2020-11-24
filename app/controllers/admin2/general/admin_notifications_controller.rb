module Admin2::General
  class AdminNotificationsController < Admin2::AdminBaseController

    def index; end

    def update_admin_notifications
      @current_community.update!(admin_notifications_params)
      flash[:notice] = t('admin2.notifications.admin_notifications_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_admin_notifications_path
    end

    private

    def admin_notifications_params
      params.require(:community).permit(:email_admins_about_new_members,
                                        :email_admins_about_new_transactions)
    end
  end
end
