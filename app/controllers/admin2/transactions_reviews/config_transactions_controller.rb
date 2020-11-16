module Admin2::TransactionsReviews
  class ConfigTransactionsController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_config
      @current_community.update!(config_params)
      render json: { message: t('admin2.notifications.configure_transactions_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def config_params
      params.require(:community).permit(:automatic_confirmation_after_days,
                                        :transaction_agreement_in_use,
                                        community_customizations_attributes:
                                          %i[id transaction_agreement_label transaction_agreement_content])
    end
  end
end
