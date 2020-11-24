class Admin::CommunityConversationsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index
    render locals: {service: @service}
  end

  def show
    if @service.conversation_transaction?
      redirect_to person_transaction_url(@current_user, {:id => @service.conversation_transaction.id}) and return
    end
    render locals: {service: @service}
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "conversations"
  end

  def set_service
    @service = Admin::ConversationsService.new(
      community: @current_community,
      params: params)
  end
end
