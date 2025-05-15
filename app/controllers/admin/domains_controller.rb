class Admin::DomainsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_presenter

  def update
    if @service.update
      redirect_to "#{APP_CONFIG.always_use_ssl ? 'https' : 'http'}://#{@service.ident}.#{APP_CONFIG.domain}", allow_other_host: true
    else
      redirect_to admin_domain_path
    end
  end

  def check_availability
    respond_to do |format|
      format.json { render :json => @service.ident_available? }
    end
  end

  def create_domain_setup
    s = @service.create_domain_setup
    if s
      redirect_to admin_domain_path
    else
      redirect_to admin_domain_path, flash: {error: t('errors.messages.domain_name_is_invalid')}
    end
  end

  def recheck_domain_setup
    @service.recheck_domain_setup
    redirect_to admin_domain_path
  end

  def reset_domain_setup
    @service.reset
    redirect_to admin_domain_path
  end

  def confirm_domain_setup
    @service.confirm_domain_setup
    redirect_to admin_domain_path
  end

  def retry_domain_setup
    @service.retry_domain_setup
    redirect_to admin_domain_path
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
