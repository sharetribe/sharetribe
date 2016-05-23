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
    alternative_cta = Maybe(ListingService::API::Api.shapes.get(community_id: @current_community.id)[:data].first)
      .map { |ls| edit_admin_listing_shape_path(ls[:name]) }
      .or_else { admin_listing_shapes_path }

    onboarding_status = Admin::OnboardingWizard.new(@current_community.id).setup_status
    links = {
      slogan_and_description: {
        sub_path: 'slogan_and_description',
        cta: admin_details_edit_path,
      },
      cover_photo: {
        sub_path: 'cover_photo',
        cta: admin_look_and_feel_edit_path,
      },
      filter: {
        sub_path: 'filter',
        cta: admin_custom_fields_path,
      },
      paypal: {
        sub_path: 'paypal',
        cta: admin_paypal_preferences_path,
        alternative_cta: alternative_cta,
      },
      listing: {
        sub_path: 'listing',
        cta: new_listing_path,
      },
      invitation: {
        sub_path: 'invitation',
        cta: new_invitation_path,
      }
    }

    sorted_steps = OnboardingViewUtils.sorted_steps_with_includes(onboarding_status, links)

    # This is the props used by the React component.
    { onboarding_guide_page: {
        onboarding_data: sorted_steps,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        info_icon: icon_tag("information"),
      }
    }
  end
end
