module TransactionService
  module DataTypes
    module Transaction

      CompletePreauthorizationPaypalResponse = EntityUtils.define_builder(
        [:payment_gateway, const_value: :paypal],
        [:pending_reason, :symbol, :optional])

      # Common response format:

      TransactionResponse = EntityUtils.define_builder(
        [:transaction, :hash, :mandatory],
        [:gateway_fields, :hash, :optional])

      module_function

      def create_complete_preauthorization_response(transaction, gateway_opts = {})
        TransactionResponse.call({
            transaction: transaction,
            gateway_fields: CompletePreauthorizationPaypalResponse.call(gateway_opts)})
      end
    end
  end
end
