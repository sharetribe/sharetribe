module ConfigRecaptcha
  extend ActiveSupport::Concern

  def validate_recaptcha(token)
    return true unless @current_community.recaptcha_configured?

    verify_recaptcha!(response: token,
                      secret_key: @current_community.recaptcha_secret_key,
                      timeout: 5)
  rescue Recaptcha::RecaptchaError => e
    logger.info('recaptcha_validate_error', nil, { error: e.message })
    return false
  end
end
