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
    sub_path = has_sub_path ? path_parts[1] : ""

    # Admin::OnboardingWizard.new(@current_community).setup_status
    onboarding_status = {
      community_id: 1,
      slogan_and_description: true,
      cover_photo: false,
      filter: true,
      paypal: false,
      listing: true,
      invitation: true
    }

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
    @app_props_server_render = {
      onboarding_guide_page: {
        path: sub_path,
        original_path: request.env['PATH_INFO'],
        onboarding_data: sorted_steps,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        info_icon: icon_tag("information"),
        translations: I18n.t('admin.onboarding.guide')
      }
    }

    @topbar_props = {
      translations: {
        progress_label: "Marketplace progress",
        next_step: "Next",
        slogan_and_description: "Add Slogan / Description",
        cover_photo: "Upload cover photo",
        filter: "Add Fields / Filters",
        paypal: "Accept payments",
        listing: "Add a listing",
        invitation: "Invite users"
      },
      progress: 83,
      next_step: 'paypal',
      guide_root: "/fi/admin/communities/501/getting_started_guide"
    }

  end
end
