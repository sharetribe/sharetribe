module Admin2::Users
  class SignupLoginController < Admin2::AdminBaseController

    def index; end

    def update_signup_login
      @current_community.update!(login_params)
      render json: { message: t('admin2.notifications.signup_login_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def login_params
      params.require(:community).permit(:facebook_connect_id,
                                        :facebook_connect_secret,
                                        :facebook_connect_enabled,
                                        :google_connect_id,
                                        :google_connect_secret,
                                        :google_connect_enabled,
                                        :linkedin_connect_id,
                                        :linkedin_connect_secret,
                                        :linkedin_connect_enabled,
                                        community_customizations_attributes: %i[id signup_info_content])
    end
  end
end
