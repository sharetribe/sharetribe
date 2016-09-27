module PaypalService::API

  class BillingAgreements

    # Include with_success for wrapping requests and responses
    include RequestWrapper

    attr_reader :logger

    MerchantData = PaypalService::DataTypes::Merchant
    TokenStore = PaypalService::Store::Token
    Lookup = PaypalService::API::Lookup
    Invnum = PaypalService::API::Invnum

    def initialize(merchant, logger = PaypalService::Logger.new)
      @logger = logger
      @merchant = merchant
      @lookup = Lookup.new(logger)
    end

    # For RequestWrapper mixin
    def paypal_merchant
      @merchant
    end

    # POST /billing_agreements/:community_id/:person_id/charge_commission
    def charge_commission(community_id, person_id, info, force_sync: true)
      @lookup.with_completed_payment(community_id, info[:transaction_id]) do |payment|
        @lookup.with_accounts(community_id, person_id, payment[:receiver_id]) do |m_acc, admin_acc|
          if(seller_is_admin?(m_acc, admin_acc))
            commission_not_applicable(community_id, info[:transaction_id], m_acc[:person_id], payment, :seller_is_admin)
          else
            if !force_sync
              proc_token = Worker.enqueue_billing_agreements_op(
                community_id: community_id,
                transaction_id: info[:transaction_id],
                op_name: :do_charge_commission,
                op_input: [community_id, info, m_acc, admin_acc, payment])

              Result::Success.new(
                DataTypes.create_process_status({
                                                  process_token: proc_token[:process_token],
                                                  completed: proc_token[:op_completed],
                                                  result: proc_token[:op_output],
                                                }))
            else
              do_charge_commission(community_id, info, m_acc, admin_acc, payment)
            end
          end
        end
      end
    end


    private

    def seller_is_admin?(m_acc, admin_acc)
      m_acc[:payer_id] == admin_acc[:payer_id]
    end

    def commission_not_applicable(community_id, transaction_id, merchant_id, payment, status)
      updated_payment = PaypalService::Store::PaypalPayment.update(
        data: payment.merge({
          commission_status: status
        }),
        community_id: community_id,
        transaction_id: transaction_id
      )
      Result::Success.new(DataTypes.create_payment(updated_payment))
    end

    def do_charge_commission(community_id, info, m_acc, admin_acc, payment)
      with_success(community_id, info[:transaction_id],
        MerchantData.create_do_reference_transaction({
            receiver_username: admin_acc[:email],
            billing_agreement_id: m_acc[:billing_agreement_billing_agreement_id],
            payment_total: info[:commission_to_admin],
            name: info[:payment_name],
            desc: info[:payment_desc] || info[:payment_name],
            invnum: Invnum.create(community_id, info[:transaction_id], :commission)
          }),
        error_policy: {
          codes_to_retry: ["10001", "x-timeout", "x-servererror"],
          try_max: 5,
          finally: (method :commission_payment_failed).call(payment)
        }
        ) do |ref_tx_res|              # Update payment
        updated_payment = PaypalService::Store::PaypalPayment.update(
          data: payment.merge({
              commission_payment_id: ref_tx_res[:payment_id],
              commission_payment_date: ref_tx_res[:payment_date],
              commission_total: ref_tx_res[:payment_total],
              commission_fee_total: ref_tx_res[:fee],
              commission_status: ref_tx_res[:payment_status],
              commission_pending_reason: ref_tx_res[:pending_reason]
          }),
          community_id: community_id,
          transaction_id: info[:transaction_id])
        # Return as payment entity
        Result::Success.new(DataTypes.create_payment(updated_payment))
      end
    end

    def mark_payment_errored(cid, txid, payment)
      PaypalService::Store::PaypalPayment.update(
        data: payment.merge({
          commission_status: :errored
        }),
        community_id: cid,
        transaction_id: txid)
    end

    def commission_payment_failed(payment)
      -> (cid, txid, request, err_response) do
        mark_payment_errored(cid, txid, payment)

        log_and_return(cid, txid, request, err_response)
      end
    end

  end
end
