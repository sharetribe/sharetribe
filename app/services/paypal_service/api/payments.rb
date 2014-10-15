module PaypalService::API

  class Payments
    # Injects a configured instance of the merchant client as paypal_merchant
    include MerchantInjector

    MerchantData = PaypalService::DataTypes::Merchant
    TokenStore = PaypalService::Store::Token

    ## POST /payments/request
    def request(create_payment)
      with_account(
        create_payment[:community_id], create_payment[:merchant_id]
      ) do |m_acc|

        with_success(MerchantData.create_set_express_checkout_order(
          create_payment.merge({ receiver_username: m_acc[:email] })
        )) do |response|
          TokenStore.create(
            create_payment[:community_id],
            response[:token],
            create_payment[:transaction_id],
            m_acc[:person_id])

          Result::Success.new(
            DataTypes.create_payment_request({
                transaction_id: create_payment[:transaction_id],
                token: response[:token],
                redirect_url: response[:redirect_url]}))
        end
      end
    end

    ## POST /payments/request/cancel?token=EC-7XU83376C70426719
    def request_cancel(token, info)
      TokenStore.delete(info[:community_id], token)
      Result::Success.new
    end

    ## POST /payments/create?token=EC-7XU83376C70426719
    def create(token, info)
      with_token(info[:community_id], token) do |token|
        with_account(info[:community_id], token[:merchant_id]) do |m_acc| # TODO Missing merchant_id in token
          with_success(MerchantData.create_get_express_checkout_details(
            { receiver_username: m_acc[:email], token: token[:token] }
          )) do |ec_details|

            # Validate that the buyer accepted and we have a payer_id now
            if (ec_details[:payer_id].nil?)
              return Result::Error.new("Payment has not been accepted by the buyer.")
            end

            with_success(MerchantData.create_do_express_checkout_payment(
              {
                receiver_username: m_acc[:email],
                token: token[:token],
                payer_id: ec_details[:payer_id],
                order_total: ec_details[:order_total]
              }
            )) do |payment_res|
              # Save payment
              payment = PaypalService::PaypalPayment::Command.create(token[:transaction_id], ec_details.merge(payment_res))

              # Delete the token, we have now completed the payment request
              TokenStore.delete(info[:community_id], token[:token])

              # Return as payment entity
              Result::Success.new(DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] })))
            end
          end
        end
      end
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

    def with_token(cid, t)
      token = TokenStore.get(cid, t)

      if (token.nil?)
        return Result::Error.new("No matching token for community_id: #{cid} and token: #{t}")
      else
        yield token
      end
    end

    def with_success(request)
      response = paypal_merchant.do_request(request)

      if (response[:success])
        yield response
      else
        Result::Error.new("Failed response from Paypal. Code: #{response[:error_code]}, msg:#{respose[:error_msg]}")
      end
    end

  end

end
