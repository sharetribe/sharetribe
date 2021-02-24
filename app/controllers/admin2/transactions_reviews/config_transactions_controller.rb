module Admin2::TransactionsReviews
  class ConfigTransactionsController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_config
      update_payment_settings
      @current_community.update!(config_params)
      render json: { message: t('admin2.notifications.configure_transactions_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    # rubocop:disable Rails/SkipsModelValidations
    def update_payment_settings
      confirmation_after_days = params[:community][:automatic_confirmation_after_days]
      return unless confirmation_after_days

      paypal_settings = PaymentSettings.paypal.find_by(community_id: @current_community.id)
      paypal_settings&.update_column(:confirmation_after_days, confirmation_after_days.to_i)

      stripe_settings = PaymentSettings.stripe.find_by(community_id: @current_community.id)
      stripe_settings&.update_column(:confirmation_after_days, confirmation_after_days.to_i)
    end
    # rubocop:enable Rails/SkipsModelValidations

    def config_params
      params.require(:community).permit(:automatic_confirmation_after_days,
                                        :transaction_agreement_in_use,
                                        community_customizations_attributes:
                                          %i[id transaction_agreement_label transaction_agreement_content])
    end
  end
end
