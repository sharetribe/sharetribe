module Admin2::Users
  class InvitationsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    private

    def set_service
      @service = Admin2::InvitationsService.new(
        community: @current_community,
        params: params)
    end
  end
end
