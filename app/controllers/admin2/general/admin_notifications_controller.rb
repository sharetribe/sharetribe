module Admin2::General
  class AdminNotificationsController < Admin2::AdminBaseController

    def index; end

    def update_admin_notifications
      @current_community.update!(admin_notifications_params)
      render json: { message: t('admin2.notifications.admin_notifications_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def admin_notifications_params
      params.require(:community).permit(:email_admins_about_new_members,
                                        :email_admins_about_new_transactions)
    end
  end
end
