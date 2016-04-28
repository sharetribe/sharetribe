class Admin::GettingStartedGuideController < ApplicationController

  before_filter :ensure_is_admin

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to root_path, flash: { error: I18n.t('error_messages.onboarding.server_rendering') }
  end

  def index
    render locals: { props: data }
  end

  private

  def data
    path_parts = request.env['PATH_INFO'].split("/getting_started_guide")
    has_sub_path = (path_parts.count == 2 && path_parts[1] != "/")
    sub_path = has_sub_path ? path_parts[1] : ""

    onboarding_status = Admin::OnboardingWizard.new(@current_community.id).setup_status
    links = {
      slogan_and_description: {
        sub_path: 'slogan_and_description',
        link: edit_details_admin_community_path(@current_community),
        info_image: view_context.image_path('onboarding/step2_sloganDescription.jpg')
      },
      cover_photo: {
        sub_path: 'cover_photo',
        link: edit_look_and_feel_admin_community_path(@current_community),
        info_image: view_context.image_path('onboarding/step3_coverPhoto.jpg')
      },
      filter: {
        sub_path: 'filter',
        link: admin_custom_fields_path,
        info_image: view_context.image_path('onboarding/step4_fieldsFilters.jpg')
      },
      paypal: {
        sub_path: 'paypal',
        link: admin_paypal_preferences_path,
        info_image: view_context.image_path('onboarding/step5_screenshot_paypal@2x.png')
      },
      listing: {
        sub_path: 'listing',
        link: new_listing_path,
        info_image: view_context.image_path('onboarding/step6_addListing.jpg')
      },
      invitation: {
        sub_path: 'invitation',
        link: new_invitation_path,
        info_image: view_context.image_path('onboarding/step7_screenshot_share@2x.png')
      }
    }

    sorted_steps = OnboardingViewUtils.sorted_steps_with_includes(onboarding_status, links)
      .each_with_object({}) { |value, hash|
        hash[value[:step]] = value.except(:step)
      }

    # This is the props used by the React component.
    { onboarding_guide_page: {
        path: sub_path,
        original_path: request.env['PATH_INFO'],
        onboarding_data: sorted_steps,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        info_icon: icon_tag("information"),
        translations: I18n.t('admin.onboarding.guide')
      }
    }
  end
end
