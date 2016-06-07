class LandingPageController < ActionController::Metal

  # Without this, got an error undefined method "helper_method"
  include ActionController::Helpers

  # We need to keep the Flash when doing redirect
  include ActionController::Flash

  # Needed for redirect and rendering routes
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  # Needed for rendering
  #
  # See Rendering Helpers: http://api.rubyonrails.org/classes/ActionController/Metal.html
  #
  include AbstractController::Rendering
  include ActionView::Layouts
  append_view_path "#{Rails.root}/app/views"

  def index
    app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
    marketplace = CurrentMarketplaceResolver.resolve_from_host(request.host, app_domain)

    if landing_page_in_use?
      landing_page(marketplace)
    else
      flash.keep
      redirect_to search_path
    end
  end

  private

  def landing_page(marketplace)
    render :landing_page
  end

  def landing_page_in_use?
    true # Add proper logic
  end
end
