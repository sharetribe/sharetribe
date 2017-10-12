class Admin::GettingStartedGuideController < Admin::AdminBaseController

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to search_path, flash: { error: I18n.t('error_messages.onboarding.server_rendering') }
  end

  def index
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :status) }
  end

  def slogan_and_description
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :slogan_and_description) }
  end

  def cover_photo
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :cover_photo) }
  end

  def filter
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :filter) }
  end

  def payment
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :payment) }
  end

  def listing
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :listing) }
  end

  def invitation
    @selected_left_navi_link = "getting_started_guide"
    render :index, locals: { props: data(page: :invitation) }
  end

  private

  def data(page:)
    listing_shape_name = ListingService::API::Api.shapes.get(community_id: @current_community.id).data.first[:name]

    onboarding_status = Admin::OnboardingWizard.new(@current_community.id).setup_status
    additional_info = {
      payment: {
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
