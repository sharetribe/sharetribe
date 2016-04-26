class Admin::GettingStartedGuideController < ApplicationController

  before_filter :ensure_is_admin

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to root_path, flash: { error: "Error prerendering in react_on_rails. See server logs." }
  end

  def index
    render locals: { props: data }
  end

  private

  def data
    path_parts = request.env['PATH_INFO'].split("/getting_started_guide")
    has_sub_path = (path_parts.count == 2 && path_parts[1] != "/")
    sub_path = has_sub_path ? path_parts[1] : "";

    onboarding_status = Admin::OnboardingWizard.new(@current_community.id).setup_status
    links = {
      slogan_and_description: {
        sub_path: 'slogan_and_description',
        link: edit_details_admin_community_path(@current_community),
        info_image: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      cover_photo: {
        sub_path: 'cover_photo',
        link: edit_look_and_feel_admin_community_path(@current_community),
        info_image: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      filter: {
        sub_path: 'filter',
        link: admin_custom_fields_path,
        info_image: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      paypal: {
        sub_path: 'paypal',
        link: admin_paypal_preferences_path,
        info_image: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      listing: {
        sub_path: 'listing',
        link: new_listing_path,
        info_image: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      invitation: {
        sub_path: 'invitation',
        link: new_invitation_path,
        info_image: view_context.image_path('onboardingImagePlaceholder.jpg')
      }
    }

    sorted_steps = OnboardingViewUtils.sorted_steps_with_includes(onboarding_status, links)
      .inject({}) { |r, i| r[i[:step]] = i.except(:step); r }

    # This is the props used by the React component.
    { onboarding_guide_page: {
        path: sub_path,
        onboarding_data: sorted_steps,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        info_icon: icon_tag("information"),
        translations: I18n.t('admin.onboarding.guide')
      }
    }
  end
end
