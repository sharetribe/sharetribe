module PaypalService::API

  class Payments
    # Injects a configured instance of the merchant client as paypal_merchant
    # include PaypalService::MerchantInjector

    # Include with_success for wrapping requests and responses
    include RequestWrapper

    attr_reader :logger

    MerchantData = PaypalService::DataTypes::Merchant
    TokenStore = PaypalService::Store::Token
    PaymentStore = PaypalService::Store::PaypalPayment

    def initialize(events, merchant, logger = PaypalService::Logger.new)
      @logger = logger
      @events = events
      @merchant = merchant
    end

    # For RequestWrapper mixin
    def paypal_merchant
      @merchant
    end

    ## POST /payments/request
    def request(community_id, create_payment)
      with_account(
        community_id, create_payment[:merchant_id]
      ) do |m_acc|

        request = MerchantData.create_set_express_checkout_order(
          create_payment.merge({
              receiver_username: m_acc[:payer_id],
              invnum: invnum(community_id, create_payment[:transaction_id])}))

        with_success(community_id, create_payment[:transaction_id],
          request,
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 3
          }
        ) do |response|
          TokenStore.create({
            community_id: community_id,
            token: response[:token],
            transaction_id: create_payment[:transaction_id],
            merchant_id: m_acc[:person_id],
            item_name: create_payment[:item_name],
            item_quantity: create_payment[:item_quantity],
            item_price: create_payment[:item_price] || create_payment[:order_total],
            express_checkout_url: response[:redirect_url]
          })

          Result::Success.new(
            DataTypes.create_payment_request({
                transaction_id: create_payment[:transaction_id],
                token: response[:token],
                redirect_url: response[:redirect_url]}))
        end
      end
    end

    ## POST /payments/request/cancel?token=EC-7XU83376C70426719
    def request_cancel(community_id, token_id)
      token = TokenStore.get(community_id, token_id)
      unless (token.nil?)
        #trigger callback for request cancelled
        @events.send(:request_cancelled, token)

        TokenStore.delete(community_id, token[:transaction_id])
        Result::Success.new
      else
        #Handle errors by logging, because request cancellations are async (direct cancels + scheduling)
        @logger.warn("Tried to cancel non-existent request: [token: #{token_id}, community: #{community_id}]")
        Result::Error.new("Tried to cancel non-existent request: [token: #{token_id}, community: #{community_id}]")
      end
    end

    ## POST /payments/:community_id/create?token=EC-7XU83376C70426719
    def create(community_id, token)
      with_token(community_id, token) do |token|
        with_payment_from_token(token) do |payment|
          authorize(
            community_id,
            payment[:transaction_id],
            PaypalService::API::DataTypes.create_authorization_info({ authorization_total: payment[:order_total] }))
        end
      end
    end

    ## POST /payments/:community_id/:transaction_id/full_capture
    def full_capture(community_id, transaction_id, info)
      with_payment(community_id, transaction_id, [[:pending, :authorization]]) do |payment, m_acc|
        with_success(community_id, transaction_id,
          MerchantData.create_do_full_capture({
              receiver_username: m_acc[:payer_id],
              authorization_id: payment[:authorization_id],
              payment_total: info[:payment_total],
              invnum: invnum(community_id, transaction_id)
          }),
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 5,
            finally: (method :void_failed_payment).call(payment, m_acc)
          }
        ) do |payment_res|

          # Save payment data to payment
          payment = PaymentStore.update(
            community_id,
            transaction_id,
            payment_res
          )

          payment_entity = DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] }))

          # Trigger payment_updated event
          @events.send(:payment_updated, payment_entity)

          # Return as payment entity
          Result::Success.new(payment_entity)
        end
      end
    end

    ## GET /payments/:community_id/:transaction_id
    def get_payment(community_id, transaction_id)
      with_payment(community_id, transaction_id) do |payment, m_acc|
        Result::Success.new(DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] })))
      end
    end

    ## POST /payments/:community_id/:transaction_id/void
    def void(community_id, transaction_id, info)
      with_payment(community_id, transaction_id, [[:pending, nil]]) do |payment, m_acc|
        with_success(community_id, transaction_id,
          MerchantData.create_do_void({
              receiver_username: m_acc[:payer_id],
              # Always void the order, it automatically voids any authorization connected to the payment
              transaction_id: payment[:order_id],
              note: info[:note]
          }),
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 5
          }
        ) do |void_res|
          with_success(community_id, transaction_id, MerchantData.create_get_transaction_details({
            receiver_username: m_acc[:payer_id],
            transaction_id: payment[:order_id],
          })) do |payment_res|
            payment = PaymentStore.update(
              community_id,
              transaction_id,
              payment_res)

            # Return as payment entity
            Result::Success.new(DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] })))
          end
        end
      end
    end

    ## POST /payments/:community_id/:transaction_id/refund
    def refund(community_id, transaction_id)
      raise NoMethodError.new("Not implemented")
    end

    ## Not part of public api, used by rake task to retry and clean unfinished orders
    def retry_and_clean_tokens(clean_time_limit)
      TokenStore.get_all.each do |token|
        response = create(token.community_id, token.token)

        if(!response[:success] && token.created_at < clean_time_limit)
          request_cancel(token.community_id, token.token)
        end
      end
    end

    private


    def with_account(cid, pid, &block)
       m_acc = PaypalService::PaypalAccount::Query.personal_account(pid, cid)
      if m_acc.nil?
        Result::Error.new("Cannot find paypal account for the given community and person: community_id: #{cid}, person_id: #{pid}.")
      else
        block.call(m_acc)
      end
    end

    def with_token(cid, t, &block)
      token = TokenStore.get(cid, t)
      if (token.nil?)
        return Result::Error.new("No matching token for community_id: #{cid} and token: #{t}")
      end

      block.call(token)
    end

    def with_merchant_account(cid, token, &block)
      m_acc = PaypalService::PaypalAccount::Query.personal_account(token[:merchant_id], cid)
      if m_acc.nil?
        return Result::Error.new("No matching merchant account for community_id: #{cid} and person_id: #{token[:merchant_id]}.")
      end

      block.call(m_acc)
    end

    def with_payment(cid, txid, accepted_states = [], &block)
      payment = PaymentStore.get(cid, txid)

      if (payment.nil?)
        return Result::Error.new("No matching payment for community_id: #{cid} and transaction_id: #{txid}.")
      end

      if (!payment_in_accepted_state?(payment, accepted_states))
        return Result::Error.new("Payment was not in accepted precondition state for the requested operation. Expected one of: #{accepted_states}, was: :#{payment[:payment_status]}, :#{payment[:pending_reason]}")
      end

      m_acc = PaypalService::PaypalAccount::Query.for_payer_id(cid, payment[:receiver_id])
      if m_acc.nil?
        return Result::Error.new("No matching merchant account for community_id: #{cid} and transaction_id: #{txid}.")
      end

      block.call(payment, m_acc)
    end

    def payment_in_accepted_state?(payment, accepted_states)
      accepted_states.empty? ||
        accepted_states.any? do |(status, reason)|
        if reason.nil?
          payment[:payment_status] == status
        else
          payment[:payment_status] == status &&
            payment[:pending_reason] == reason
        end
      end
    end

    def handle_failed_create_payment(token)
      -> (cid, txid, request, err_response) do
        data =
          if err_response[:error_code] == "10486"
            {redirect_url: token[:express_checkout_url]}
          else
            nil
          end

        log_and_return(cid, txid, request, err_response, data)
      end
    end

    def handle_failed_authorization(payment)
      -> (cid, txid, request, err_response) do
        if err_response[:error_code] == "10486"
          # Special handling for 10486 error. Return error response and do NOT void.
          token = PaypalService::Store::Token.get_for_transaction(payment[:community_id], payment[:transaction_id])
          redirect_url_without_token = remove_token(token[:express_checkout_url])
          redirect_url_with_order = append_order_id(redirect_url_without_token, payment[:order_id])
          log_and_return(cid, txid, request, err_response, {redirect_url: "#{redirect_url_with_order}"})
        else
          void_failed_payment(payment, m_acc).call(payment[:community_id], payment[:transaction_id], request, err_response)
        end
      end
    end

    def void_failed_payment(payment, m_acc)
      -> (cid, txid, request, err_response) do
        with_success(cid, txid,
          MerchantData.create_do_void({
              receiver_username: m_acc[:payer_id],
              # Always void the order, it automatically voids any authorization connected to the payment
              transaction_id: payment[:order_id]
            }),
          error_policy: {
            retry_codes: ["10001", "x-timeout", "x-servererror"],
            try_max: 3
          }
          ) do |void_res|
          with_success(cid, txid,
            MerchantData.create_get_transaction_details({
                receiver_username: m_acc[:payer_id],
                transaction_id: payment[:order_id],
              }),
            error_policy: {
              retry_codes: ["10001", "x-timeout", "x-servererror"],
              try_max: 3
            }
            ) do |payment_res|
            payment = PaymentStore.update(
              payment[:community_id],
              payment[:transaction_id],
              payment_res)

            # Return original error
            log_and_return(cid, txid, request, err_response)
          end
        end
      end
    end

    def invnum(community_id, transaction_id)
      "#{community_id}-#{transaction_id}"
    end

    def append_order_id(url_str, order_id)
      URLUtils.append_query_param(url_str, "order_id", order_id)
    end

    def remove_token(url_str, token)
      URLUtils.remove_query_param(url_str, "token")
    end

    def with_payment_from_token(token, &block)
      existing_payment = PaymentStore.get(token[:community_id], token[:transaction_id])

      if existing_payment
        block.call(existing_payment)
      else
        response = create_payment(token)
        if(response[:success])
          block.call(response[:data])
        else
          response
        end
      end
    end

    def create_payment(token)
      with_merchant_account(token[:community_id], token) do |m_acc|
        with_success(token[:community_id], token[:transaction_id],
          MerchantData.create_get_express_checkout_details(
            { receiver_username: m_acc[:payer_id], token: token[:token] }
          ),
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 3
          }
        ) do |ec_details|

          # Validate that the buyer accepted and we have a payer_id now
          if (ec_details[:payer_id].nil?)
            return Result::Error.new("Payment has not been accepted by the buyer.")
          end

          with_success(token[:community_id], token[:transaction_id],
            MerchantData.create_do_express_checkout_payment({
              receiver_username: m_acc[:payer_id],
              token: token[:token],
              payer_id: ec_details[:payer_id],
              order_total: ec_details[:order_total],
              item_name: token[:item_name],
              item_quantity: token[:item_quantity],
              item_price: token[:item_price],
              invnum: invnum(token[:community_id], token[:transaction_id])
            }),
            error_policy: {
              codes_to_retry: ["10001", "x-timeout", "x-servererror"],
              try_max: 3,
              finally: (method :handle_failed_create_payment).call(token)
            }
          ) do |payment_res|
            # Save payment
            payment = PaymentStore.create(
              token[:community_id],
              token[:transaction_id],
              ec_details.merge(payment_res))

            payment_entity = DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] }))

            # Send event payment_crated
            @events.send(:payment_created, payment_entity)

            # Return as payment entity
            Result::Success.new(payment_entity)
          end
        end
      end
    end

    def authorize(community_id, transaction_id, info)
      with_payment(community_id, transaction_id, [[:pending, :order]]) do |payment, m_acc|
        with_success(community_id, transaction_id,
          MerchantData.create_do_authorization({
              receiver_username: m_acc[:payer_id],
              order_id: payment[:order_id],
              authorization_total: info[:authorization_total]
          }),
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 5,
            finally: (method :handle_failed_authorization).call(payment)
          }
        ) do |auth_res|

          # Delete the token, we have now completed the payment request
          TokenStore.delete(community_id, transaction_id)

          # Save authorization data to payment
          payment = PaymentStore.update(community_id, transaction_id, auth_res)
          payment_entity = DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] }))

          # Trigger callback for authorized
          @events.send(:payment_updated, payment_entity)

          # Return as payment entity
          Result::Success.new(payment_entity)
        end
      end
    end

  end

end
