class Admin::PlansController < Admin::AdminBaseController

  # Redirect to the subscription information page, if one is configured.
  # Otherwise, redirect to external plan service. Nothing else.
  def show
    subscription_url = APP_CONFIG.external_plan_service_subscription_url.presence
    return redirect_to(subscription_url, allow_other_host: true) if subscription_url

    marketplace_default_name = @current_community.name(@current_community.default_locale)

    PlanService::API::API.plans.get_external_service_link(
      id: @current_community.id,
      ident: @current_community.ident,
      domain: @current_community.use_domain? ? @current_community.domain : nil,
      marketplace_default_name: marketplace_default_name
    ).on_success { |link|
      redirect_to link, allow_other_host: true
    }.on_error { |error_msg|
      render_not_found!(error_msg)
    }
  end

end
