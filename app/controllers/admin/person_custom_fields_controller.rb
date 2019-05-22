class Admin::PersonCustomFieldsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def new
    @service.new_custom_field
  end

  def create
    success = @service.create
    if success
      redirect_to admin_person_custom_fields_path
    else
      flash[:error] = I18n.t('admin.person_custom_fields.saving_failed')
      render :new
    end
  end

  def edit
    @service.find_custom_field
  end

  def update
    @service.update
    redirect_to admin_person_custom_fields_path
  end

  def destroy
    @service.destroy
    redirect_to admin_person_custom_fields_path
  end

  def order
    @service.order
    render body: nil, status: 200
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "user_fields"
  end

  def set_service
    @service = Admin::PersonCustomFieldsService.new(
      community: @current_community,
      params: params)
  end
end
