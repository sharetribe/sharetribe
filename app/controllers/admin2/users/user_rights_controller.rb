module Admin2::Users
  class UserRightsController < Admin2::AdminBaseController

    def index
      @community_customizations = find_or_initialize_customizations(@current_community.locales)
    end

    def update_user_rights
      @current_community.update!(update_user_params)
      render json: { message: t('admin2.notifications.user_rights_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def update_user_params
      params.require(:community).permit(:join_with_invite_only,
                                        :users_can_invite_new_users,
                                        :allow_free_conversations,
                                        :require_verification_to_post_listings)
    end
  end
end
