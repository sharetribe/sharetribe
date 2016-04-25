class Styleguide::PagesController < ApplicationController
  include ReactOnRails::Controller
  layout "styleguide"

  before_action :data

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to styleguide_path,
                flash: { error: "Error prerendering in react_on_rails. See server logs." }
  end

  private

  def data
    path_parts = request.env['PATH_INFO'].split("/getting_started_guide")
    has_sub_path = (path_parts.count == 2 && path_parts[1] != "/")
    sub_path = has_sub_path ? path_parts[1] : "";

    # Admin::OnboardingWizard.new(@current_community).setup_status
    onboarding_status = {
      community_id: 1,
      slogan_and_description: true,
      cover_photo: false,
      filter: true,
      paypal: true,
      listing: true,
      invitation: true
    }

    links_to_rails_routes = {
      slogan_and_description: {
        link: edit_details_admin_community_path(@current_community),
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      cover_photo: {
        link: edit_look_and_feel_admin_community_path(@current_community),
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      filter: {
        link: admin_custom_fields_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      paypal: {
        link: admin_paypal_preferences_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      listing: {
        link: new_listing_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      invitation: {
        link: new_invitation_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      }
    }

    onboarding_data = links_to_rails_routes.map { |k, v|
      v[:status] = onboarding_status[k]
      { k => v }
    }.reduce(:merge)

    # This is the props used by the React component.
    @app_props_server_render = {
      onboardingGuidePage: {
        path: sub_path,
        onboarding_data: onboarding_data,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        translations: I18n.t('admin.onboarding.guide')
      }
    }

  end
end
