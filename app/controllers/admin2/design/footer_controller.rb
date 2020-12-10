module Admin2::Design
  class FooterController < Admin2::AdminBaseController
    before_action :find_customizations
    before_action :set_service

    def index; end

    def update_footer
      return if @service.plan_footer_disabled?
      unless @service.update
        raise t('admin2.notifications.footer_update_failed')
      end

      render layout: false
    rescue StandardError => e
      @error = e.message
      render layout: false, status: :unprocessable_entity
    end

    private

    def set_service
      @service = Admin2::FooterService.new(
        community: @current_community,
        params: params,
        plan: @current_plan)
    end
  end
end
