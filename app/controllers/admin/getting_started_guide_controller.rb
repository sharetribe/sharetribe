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
    listing_shape_name = ListingService::API::Api.shapes.get(community_id: @current_community.id).data.first[:name]

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
      },
      paypal: {
        sub_path: 'paypal',
        additional_info: {
          listing_shape_name: listing_shape_name
        }
      },
      listing: {
        sub_path: 'listing',
      },
      invitation: {
        sub_path: 'invitation',
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
