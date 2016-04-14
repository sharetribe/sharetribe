class Admin::GettingStartedGuideController < ApplicationController

  before_filter :ensure_is_admin
  before_action :data

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to root_path, flash: { error: "Error prerendering in react_on_rails. See server logs." }
  end

  # See files in spec/dummy/app/views/pages

  private

  def data
    path_parts = request.env['PATH_INFO'].split("/getting_started_guide")
    has_deep_path = !(path_parts.count == 1 || path_parts == "")
    path_string = has_deep_path ? path_parts[1] : "";

    onboarding_status = Admin::OnboardingWizard.new(@current_community).setup_status

    # This is the props used by the React component.
    @app_props_server_render = {
      onboardingGuidePage: {
        path: path_string,
        onboarding_status: onboarding_status,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        translations: I18n.t('admin.onboarding.guide')
      }
    }
  end
end