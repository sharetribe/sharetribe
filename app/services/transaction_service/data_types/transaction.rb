module TransactionService
  module DataTypes
    module Transaction

      CompeletePreauthorizationPaypalResponse = EntityUtils.define_builder(
        [:payment_gateway, const_value: :paypal],
        [:pending_reason, one_of: [:multicurrency, nil]])

      # Common response format:

      TransactionResponse = EntityUtils.define_builder(
        [:transaction, :hash, :mandatory],
        [:gateway_fields, :hash, :optional])

      module_function

      def create_complete_preauthorization_response(transaction, gateway_fields); TransactionResponse.call(opts) end
    end
  end
end
