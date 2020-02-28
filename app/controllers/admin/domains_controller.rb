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

  def check_domain_availability
    state = @service.check_domain_availability
    case state
    when Community::DomainChecker::PENDING
      redirect_to pending_admin_domain_path
    when Community::DomainChecker::PASSED
      redirect_to passed_admin_domain_path
    when Community::DomainChecker::FAILED
      redirect_to failed_admin_domain_path
    when Community::DomainChecker::PASSED_WITH_WARNING
      redirect_to passed_with_warning_admin_domain_path
    else
      redirect_to pending_admin_domain_path
    end
  end

  def pending; end

  def passed; end

  def failed; end

  def passed_with_warning; end

  def reset
    @service.reset
    redirect_to admin_domain_path
  end

  def set
    # no action at the moment
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
