class Admin2::DashboardController < Admin2::AdminBaseController

  def index
    service = Admin::DomainsService.new(
      community: @current_community,
      plan: @current_plan,
      params: params
    )
    @presenter = Admin::DomainsPresenter.new(service: service)
    @block = block_select
  end

  private

  def block_select
    whitelabel = @current_plan[:features][:whitelabel]
    landing_page = @current_plan[:features][:landing_page]
    if whitelabel && !landing_page
      'b'
    elsif whitelabel && landing_page
      'c'
    else
      'a'
    end
  end
end
