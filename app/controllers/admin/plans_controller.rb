class Admin::PlansController < Admin::AdminBaseController

  # Redirect to external plan service. Nothing else.
  def show
    marketplace_default_name = @current_community.name(@current_community.default_locale)

    PlanService::API::Api.plans.get_external_service_link(
      id: @current_community.id,
      ident: @current_community.ident,
      domain: @current_community.use_domain? ? @current_community.domain : nil,
      marketplace_default_name: marketplace_default_name
    ).on_success { |link|
      redirect_to link
    }.on_error { |error_msg|
      render_not_found!(error_msg)
    }
  end

end
