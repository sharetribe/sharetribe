module PaypalService::API

  class Payments
    include MerchantInjector

    ## POST /payments/request
    def request(create_payment_request)
      raise NoMethodError.new("Not implemented")
    end

    ## POST /payments/request/cancel?token=EC-7XU83376C70426719
    def request_cancel(token, token_verification_info)
      raise NoMethodError.new("Not implemented")
    end

    ## POST /payments/create?token=EC-7XU83376C70426719
    def create(token, token_verification_info)
      raise NoMethodError.new("Not implemented")
    end

    ## POST /payments/:transaction_id/authorize
    def authorize(transaction_id, authorization_info)
      raise NoMethodError.new("Not implemented")
    end

    ## POST /payments/:transaction_id/full_capture
    def full_capture(transaction_id, payment_info)
      raise NoMethodError.new("Not implemented")
    end

    ## GET /payments/:transaction_id
    def get_payment(transaction_id)
      raise NoMethodError.new("Not implemented")
    end

    ## POST /payments/:transaction_id/void
    def void(transaction_id)
      raise NoMethodError.new("Not implemented")
    end

    ## POST /payments/:transaction_id/refund
    def refund(transaction_id)
      raise NoMethodError.new("Not implemented")
    end

  end

end
