class Admin::LandingPageVersionsController < Admin::AdminBaseController
  before_action :ensure_plan
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  def release
    if @service.release_landing_page_version
      link = ActionController::Base.helpers.link_to I18n.t('admin.communities.landing_pages.check_it_out'),
        landing_page_without_locale_path, target: '_blank', rel: 'noopener'
      flash[:notice] = I18n.t('admin.communities.landing_pages.latest_version_released', link: link).html_safe # rubocop:disable Rails/OutputSafety
    else
      flash[:error] = I18n.t('admin.communities.landing_pages.this_version_is_not_released')
    end
    redirect_to admin_landing_page_versions_path
  end

  def update
    @service.update_landing_page_version
    render body: 'OK'
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "landing_page"
  end

  def set_service
    @service = CustomLandingPage::EditorService.new(
      community: @current_community,
      params: params)
    @service.ensure_latest_version_exists!
    @presenter = CustomLandingPage::EditorPresenter.new(service: @service)
  end

  def ensure_plan
    unless @current_plan.try(:[], :features).try(:[], :landing_page)
      redirect_to admin_landing_page_path and return
    end
  end
end
