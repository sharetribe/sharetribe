module Admin2::Users
  class UserFieldsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def new
      @service.new_custom_field
      render layout: false
    end

    def edit
      @service.find_custom_field
      render layout: false
    end

    def update
      @service.update
      flash[:notice] = t('admin2.notifications.user_field_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_users_user_fields_path
    end

    def create
      success = @service.create
      raise I18n.t('admin2.notifications.user_field_saving_failed') unless success
      flash[:notice] = t('admin2.notifications.user_field_created')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_users_user_fields_path
    end

    def delete_popup
      @service.find_custom_field
      render layout: false
    end

    def destroy
      @service.destroy
      redirect_to admin2_users_user_fields_path
    end

    def order
      @service.order
      head :ok
    end

    private

    def set_service
      @service = Admin::PersonCustomFieldsService.new(
        community: @current_community,
        params: params)
    end

  end
end
