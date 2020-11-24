module Admin2::TransactionsReviews
  class ConversationsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    private

    def set_service
      @service = Admin2::ConversationsService.new(
        community: @current_community,
        params: params)
    end
  end
end
