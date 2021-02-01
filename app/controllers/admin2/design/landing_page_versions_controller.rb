module Admin2::Design
  class LandingPageVersionsController < Admin2::AdminBaseController
    before_action :set_service, except: :valid_listing
    before_action :ensure_plan, except: :valid_listing

    def index; end

    def valid_listing
      listing_exist = @current_community.listings.where(id: params[:id]).present?
      render json: { listing_exist: listing_exist }
    end

    def release
      if @service.release_landing_page_version
        link = ActionController::Base.helpers.link_to I18n.t('admin2.landing_page.check_it_out'),
                                                      landing_page_without_locale_path, target: :_blank, rel: :noopener
        flash[:notice] = I18n.t('admin2.landing_page.latest_version_released', link: link).html_safe # rubocop:disable Rails/OutputSafety
      else
        flash[:error] = I18n.t('admin2.landing_page.this_version_is_not_released')
      end
      redirect_to admin2_design_landing_page_versions_path
    end

    def update
      @service.update_landing_page_version
      head :ok
    end

    private

    def set_service
      @service = CustomLandingPage::EditorService.new(
          community: @current_community,
          params: params)
      @service.ensure_latest_version_exists!
      @presenter = CustomLandingPage::EditorPresenter.new(service: @service)
    end

    def ensure_plan
      @allowed_lp = @current_plan.try(:[], :features).try(:[], :landing_page)
    end
  end
end
