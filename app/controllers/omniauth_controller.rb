class OmniauthController < ApplicationController
  def facebook
    create_omniauth
  end

  def google_oauth2
    create_omniauth
  end

  def linkedin
    create_omniauth
  end

  # Callback from Omniauth failures
  def failure
    origin_locale = get_origin_locale(request, available_locales())
    I18n.locale = origin_locale if origin_locale
    error_message = params[:error_reason] || "login error"
    kind = request.env["omniauth.error.strategy"].name.to_s || "Facebook"
    flash[:error] = t("devise.omniauth_callbacks.failure",:kind => kind.humanize, :reason => error_message.humanize)
    redirect_to search_path
  end

  def passthru
    render status: :not_found, plain: "Not found. Authentication passthru."
  end

  private

  def get_origin_locale(request, available_locales)
    locale_string ||= URLUtils.extract_locale_from_url(request.env['omniauth.origin']) if request.env['omniauth.origin']
    if locale_string && available_locales.include?(locale_string)
      locale_string
    end
  end

  def create_omniauth
    origin_locale = get_origin_locale(request, available_locales())
    I18n.locale = origin_locale if origin_locale

    service = Person::OmniauthService.new(
      community: @current_community,
      request: request,
      logger: logger)

    if service.person
      service.update_person_provider_uid
      flash[:notice] = t("devise.omniauth_callbacks.success", kind: service.provider_name)
      sign_in_and_redirect service.person, :event => :authentication
    elsif service.no_ominauth_email?
      flash[:error] = t("layouts.notifications.could_not_get_email_from_social_network", provider: service.provider_name)
      redirect_to sign_up_path and return
    elsif service.person_email_unconfirmed
      flash[:error] = t("layouts.notifications.social_network_email_unconfirmed", email: service.email, provider: service.provider_name)
      redirect_to login_path and return
    else
      @new_person = service.create_person

      sign_in(:person, @new_person)
      flash[:notice] = t("layouts.notifications.login_successful", person_name: view_context.link_to(PersonViewUtils.person_display_name_for_type(@new_person, "first_name_only"), person_path(@new_person))).html_safe # rubocop:disable Rails/OutputSafety


      session[:fb_join] = "pending_analytics"

      record_event(flash, "SignUp", method: service.provider.to_sym)

      redirect_to pending_consent_path
    end
  end
end
