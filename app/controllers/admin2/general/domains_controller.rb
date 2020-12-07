module Admin2::General
  class DomainsController < Admin2::AdminBaseController
    before_action :set_presenter

    def index; end

    def test_dns
      @domain = params[:domain] || @presenter.domain_checked
      render layout: false
    end

    def recheck_domain_setup
      @service.recheck_domain_setup
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_domains_path
    end

    def reset_domain_setup
      @service.reset
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_domains_path
    end

    def confirm_domain_setup
      @service.confirm_domain_setup
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_domains_path
    end

    def retry_domain_setup
      @service.retry_domain_setup
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_domains_path
    end

    def create_domain_setup
      s = @service.create_domain_setup
      raise t('errors.messages.domain_name_is_invalid') unless s
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_domains_path
    end

    private

    def set_presenter
      @service = Admin::DomainsService.new(
          community: @current_community,
          plan: @current_plan,
          params: params
      )
      @presenter = Admin::DomainsPresenter.new(service: @service)
    end
  end
end
