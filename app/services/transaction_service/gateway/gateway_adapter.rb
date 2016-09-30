module TransactionService::Gateway

  class GatewayAdapter

    # Returns true or false indicating if the gateway adapter supports
    # the given transaction process.
    def supports_process(process)
      raise InterfaceMethodNotImplementedError.new
    end


    # Create payment based on the newly created transaction and,
    # optionally, gateway specific data passed in gateway_fields.
    #
    # Implementations can be asked to implement the operation
    # asynchronously but the final choice is up to adapter
    # implementation.
    #
    # Returns a Completion( Result( gateway_specific_response) )
    def create_payment(tx:, gateway_fields:, force_sync:)
      raise InterfaceMethodNotImplementedError.new
    end

    def reject_payment(tx:, reason:)
      raise InterfaceMethodNotImplementedError.new
    end

    def complete_preauthorization(tx:)
      raise InterfaceMethodNotImplementedError.new
    end

    def get_payment_details(tx:)
      raise InterfaceMethodNotImplementedError.new
    end
  end
end
