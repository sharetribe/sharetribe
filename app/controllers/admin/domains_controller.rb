class Admin::DomainsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_presenter

  def update
    if @service.update
      redirect_to "#{APP_CONFIG.always_use_ssl ? 'https' : 'http'}://#{@service.ident}.#{APP_CONFIG.domain}"
    else
      redirect_to admin_domain_path
    end
  end

  def check_availability
    respond_to do |format|
      format.json { render :json => @service.ident_available? }
    end
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'domain'
  end

  def set_presenter
    @service = Admin::DomainsService.new(
      community: @current_community,
      plan: @current_plan,
      params: params
    )
    @presenter = Admin::DomainsPresenter.new(
      service: @service
    )
  end
end
