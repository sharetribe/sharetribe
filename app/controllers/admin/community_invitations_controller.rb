class Admin::CommunityInvitationsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "invitations"
  end

  def set_service
    @service = Admin::InvitationsService.new(
      community: @current_community,
      params: params)
  end
end
