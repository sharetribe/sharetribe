module PaypalService::API

  class Payments

    # Include with_success for wrapping requests and responses
    include RequestWrapper

    attr_reader :logger

    MerchantData = PaypalService::DataTypes::Merchant
    TokenStore = PaypalService::Store::Token
    PaymentStore = PaypalService::Store::PaypalPayment
    Lookup = PaypalService::API::Lookup
    Worker = PaypalService::API::Worker

    def initialize(events, merchant, logger = PaypalService::Logger.new)
      @logger = logger
      @events = events
      @merchant = merchant
    end

    # For RequestWrapper mixin
    def paypal_merchant
      @merchant
    end


    # The API implementation
    #

    ## POST /payments/request
    def request(community_id, create_payment, async: false)
      Lookup.with_account(
        community_id, create_payment[:merchant_id]
      ) do |m_acc|
        if (async)
          proc_token = Worker.enqueue_payments_op(
            community_id: community_id,
            transaction_id: create_payment[:transaction_id],
            op_name: :do_request,
            op_input: [community_id, create_payment, m_acc])

          proc_status_response(proc_token)
        else
          do_request(community_id, create_payment, m_acc)
        end
      end
    end

    def do_request(community_id, create_payment, m_acc)
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

    def get_request_token(community_id, token)
      Lookup.with_token(community_id, token) do |token|
        Result::Success.new(token)
      end
    end

    ## POST /payments/request/cancel?token=EC-7XU83376C70426719
    def request_cancel(community_id, token_id)
      token = TokenStore.get(community_id, token_id)
      unless (token.nil?)
        TokenStore.delete(community_id, token[:transaction_id])

        #trigger callback for request cancelled
        @events.send(:request_cancelled, :success, token)

        Result::Success.new
      else
        #Handle errors by logging, because request cancellations are async (direct cancels + scheduling)
        @logger.warn("Tried to cancel non-existent request: [token: #{token_id}, community: #{community_id}]")
        Result::Error.new("Tried to cancel non-existent request: [token: #{token_id}, community: #{community_id}]")
      end
    end

    ## POST /payments/:community_id/create?token=EC-7XU83376C70426719
    def create(community_id, token, async: false)
      Lookup.with_token(community_id, token) do |token|
        if (async)
          proc_token = Worker.enqueue_payments_op(
            community_id: community_id,
            transaction_id: token[:transaction_id],
            op_name: :do_create,
            op_input: [community_id, token])

          proc_status_response(proc_token)
        else
          do_create(community_id, token)
        end
      end
    end

    def do_create(community_id, token)
      payment = Lookup.get_payment_by_token(token)

      # The process either starts by creating a new payment...
      if (payment.nil?)
        payment_res = create_payment(token)
        if (payment_res[:success])
          authorize_payment(community_id, payment_res[:data])
        else
          payment_res
        end
        # ... or continues from a previously created but not yet authorized payment
      else
        authorize_payment(community_id, payment)
      end
    end

    ## POST /payments/:community_id/:transaction_id/full_capture
    def full_capture(community_id, transaction_id, info, async: false)
      Lookup.with_payment(community_id, transaction_id, [[:pending, :authorization]]) do |payment, m_acc|
        if (async)
          proc_token = Worker.enqueue_payments_op(
            community_id: community_id,
            transaction_id: transaction_id,
            op_name: :do_full_capture,
            op_input: [community_id, transaction_id, info, payment, m_acc])

          proc_status_response(proc_token)
        else
          do_full_capture(community_id, transaction_id, info, payment, m_acc)
        end
      end
    end

    def do_full_capture(community_id, transaction_id, info, payment, m_acc)
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
        @events.send(:payment_updated, :success, payment_entity)

        # Return as payment entity
        Result::Success.new(payment_entity)
      end
    end

    ## GET /payments/:community_id/:transaction_id
    def get_payment(community_id, transaction_id)
      Lookup.with_payment(community_id, transaction_id) do |payment, m_acc|
        Result::Success.new(DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] })))
      end
    end

    ## POST /payments/:community_id/:transaction_id/void
    def void(community_id, transaction_id, info, async: false)
      Lookup.with_payment(community_id, transaction_id, [[:pending, nil]]) do |payment, m_acc|
        if (async)
          proc_token = Worker.enqueue_payments_op(
            community_id: community_id,
            transaction_id: transaction_id,
            op_name: :do_void,
            op_input: [community_id, transaction_id, info, payment, m_acc])

          proc_status_response(proc_token)
        else
          do_void(community_id, transaction_id, info, payment, m_acc)
        end
      end
    end

    def do_void(community_id, transaction_id, info, payment, m_acc)
      void_payment(
        community_id,
        transaction_id,
        payment,
        :success,
        m_acc,
        info[:note])
    end

    ## POST /payments/:community_id/:transaction_id/refund
    def refund(community_id, transaction_id)
      raise NoMethodError.new("Not implemented")
    end

    ## Not part of the public API, used by rake task to retry and clean unfinished orders
    def retry_and_clean_tokens(clean_time_limit)
      TokenStore.get_all.each do |token|
        response = create(token.community_id, token.token)

        if(!response[:success] && token.created_at < clean_time_limit)
          request_cancel(token.community_id, token.token)
        end
      end
    end


    private


    # Reusable bits of the API operations
    #

    def create_payment(token)
      Lookup.with_merchant_account(token[:community_id], token) do |m_acc|
        with_success(token[:community_id], token[:transaction_id],
          MerchantData.create_get_express_checkout_details(
            { receiver_username: m_acc[:payer_id], token: token[:token] }
          ),
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 3,
            finally: method(:handle_failed_create_payment).call(token),
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
            @events.send(:payment_created, :success, payment_entity)

            # Return as payment entity
            Result::Success.new(payment_entity)
          end
        end
      end
    end

    def authorize_payment(community_id, payment)
      Lookup.with_payment(community_id, payment[:transaction_id], [[:pending, :order]]) do |payment, m_acc|
        with_success(community_id, payment[:transaction_id],
          MerchantData.create_do_authorization({
              receiver_username: m_acc[:payer_id],
              order_id: payment[:order_id],
              authorization_total: payment[:order_total]
          }),
          error_policy: {
            codes_to_retry: ["10001", "x-timeout", "x-servererror"],
            try_max: 5,
            finally: (method :handle_failed_authorization).call(payment, m_acc)
          }
        ) do |auth_res|

          # Delete the token, we have now completed the payment request
          TokenStore.delete(community_id, payment[:transaction_id])

          # Save authorization data to payment
          payment = PaymentStore.update(community_id, payment[:transaction_id], auth_res)
          payment_entity = DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] }))

          # Trigger callback for authorized
          @events.send(:payment_updated, :success, payment_entity)

          # Return as payment entity
          Result::Success.new(payment_entity)
        end
      end
    end

    def void_payment(community_id, transaction_id, payment, flow, m_acc, note = nil)
      with_success(community_id, transaction_id,
        MerchantData.create_do_void({
            receiver_username: m_acc[:payer_id],
            # Always void the order, it automatically voids any authorization connected to the payment
            transaction_id: payment[:order_id],
            note: note
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

          payment_entity = DataTypes.create_payment(payment.merge({ merchant_id: m_acc[:person_id] }))

          # Trigger payment_updated
          @events.send(:payment_updated, flow, payment_entity)

          Result::Success.new(payment_entity)
        end
      end
    end

    def invnum(community_id, transaction_id)
      "#{community_id}-#{transaction_id}"
    end

    def proc_status_response(proc_token)
      Result::Success.new(
        DataTypes.create_process_status({
            process_token: proc_token[:process_token],
            completed: proc_token[:op_completed],
            result: proc_token[:op_output]}))
    end


    # Error handlers
    #

    def handle_failed_create_payment(token)
      -> (cid, txid, request, err_response) do
        data =
          if err_response[:error_code] == "10486"
            {redirect_url: token[:express_checkout_url]}
          else
            request_cancel(cid, token[:token])
            nil
          end

        log_and_return(cid, txid, request, err_response, data || {})
      end
    end

    def handle_failed_authorization(payment, m_acc)
      -> (cid, txid, request, err_response) do
        if err_response[:error_code] == "10486"
          # Special handling for 10486 error. Return error response and do NOT void.
          token = PaypalService::Store::Token.get_for_transaction(payment[:community_id], payment[:transaction_id])
          redirect_url = append_order_id(remove_token(token[:express_checkout_url]), payment[:order_id])
          log_and_return(cid, txid, request, err_response, {redirect_url: "#{redirect_url}"})
        else
          void_failed_payment(payment, m_acc).call(payment[:community_id], payment[:transaction_id], request, err_response)
        end
      end
    end

    def void_failed_payment(payment, m_acc)
      -> (cid, txid, request, err_response) do
        void_payment(cid, txid, payment, :error, m_acc)

        # Return original error
        log_and_return(cid, txid, request, err_response)
      end
    end

    def append_order_id(url_str, order_id)
      URLUtils.append_query_param(url_str, "order_id", order_id)
    end

    def remove_token(url_str)
      URLUtils.remove_query_param(url_str, "token")
    end

  end
end
