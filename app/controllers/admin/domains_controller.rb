class Admin::DomainsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_presenter

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'domain'
  end

  def set_presenter
    @presenter = Admin::DomainsPresenter.new(
      community: @current_community,
      plan: @current_plan
    )
  end
end
