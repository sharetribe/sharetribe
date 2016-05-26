class Admin::GettingStartedGuideController < ApplicationController

  before_filter :ensure_is_admin

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to root_path, flash: { error: I18n.t('error_messages.onboarding.server_rendering') }
  end

  def index
    render :index, locals: { props: data(:status) }
  end

  def slogan_and_description
    render :index, locals: { props: data(:slogan_and_description) }
  end

  def cover_photo
    render :index, locals: { props: data(:cover_photo) }
  end

  def filter
    render :index, locals: { props: data(:filter) }
  end

  def paypal
    render :index, locals: { props: data(:paypal) }
  end

  def listing
    render :index, locals: { props: data(:listing) }
  end

  def invitation
    render :index, locals: { props: data(:invitation) }
  end

  private

  def data(page)
    listing_shape_name = ListingService::API::Api.shapes.get(community_id: @current_community.id).data.first[:name]

    onboarding_status = Admin::OnboardingWizard.new(@current_community.id).setup_status
    additional_info = {
      paypal: {
        additional_info: {
          listing_shape_name: listing_shape_name
        }
      },
    }

    sorted_steps = OnboardingViewUtils.sorted_steps_with_includes(onboarding_status, additional_info)

    # This is the props used by the React component.
    { onboarding_guide_page: {
        page: page,
        onboarding_data: sorted_steps,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        info_icon: icon_tag("information"),
      }
    }
  end
end
