module PaypalService::API

  class Payments
    # Injects a configured instance of the merchant client as paypal_merchant
    include MerchantInjector

    MerchantData = PaypalService::DataTypes::Merchant

    ## POST /payments/request
    def request(create_payment)
      with_account(
        create_payment[:community_id], create_payment[:merchant_id]
        ) do |merchant_account|

        request = MerchantData.create_set_express_checkout_order(
          create_payment.merge(
            { receiver_username: merchant_account[:email]}
          )
        )

        with_success(paypal_merchant.do_request(request)) do |response|
          Token::Command.create(
            response[:token],
            create_payment_request[:transaction_id])

          Result::Success.new(
            DataTypes.create_payment_request({
                transaction_id: create_payment_request[:transaction_id],
                token: response[:token],
                redirect_url: response[:redirect_url]}))
        end
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

    private

    def with_account(cid, pid)
       m_acc = PaypalService::PaypalAccount::Query.personal_account(pid, cid)
      if m_acc.nil?
        Result::Error.new("Cannot find paypal account for the given community and person: community_id: #{cid}, person_id: #{pid}.")
      else
        yield m_acc
      end
    end

    def with_success(response)
      if (response[:success])
        yield response
      else
        Result::Error.new("Failed response from Paypal. Code: #{response[:error_code]}, msg:#{respose[:error_msg]}")
      end
    end

  end

end
