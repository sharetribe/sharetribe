module Admin2::Advanced
  class RecaptchaController < Admin2::AdminBaseController

    def index; end

    def update_recaptcha
      @current_community.update!(recaptcha_params)
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def recaptcha_params
      params.require(:community).permit(:recaptcha_site_key, :recaptcha_secret_key)
    end
  end
end
