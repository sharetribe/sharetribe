module PaypalService::API

  class Payments
    include MerchantInjector

    MerchantData = PaypalService::DataTypes::Merchant

    ## POST /payments/request
    def request(create_payment_request)
      merchant_account = PaypalService::PaypalAccount::Query.personal_account(
        create_payment_request[:merchant_id],
        create_payment_request[:community_id])
      if merchant_account.nil?
        return Result::Error.new("Cannot find paypal account for the given merchant id: #{create_payment_request[:merchant_id]}")
      end

      request = MerchantData.create_set_express_checkout_order(
        create_payment_request.merge(
          { receiver_username: merchant_account[:email]}))

      response = paypal_merchant.do_request(request)

      if (response[:success])
        Token::Command.create(
          response[:token],
          create_payment_request[:transaction_id])

        Result::Success.new(
          DataTypes.create_payment_request({
              transaction_id: create_payment_request[:transaction_id],
              token: response[:token],
              redirect_url: response[:redirect_url]}))
      else
        Result::Error.new("#{response[:error_code]}: #{response[:error_msg]}")
      end
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
