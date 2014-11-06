module PaypalService::API

  class BillingAgreements
    # Injects a configured instance of the merchant client as paypal_merchant
    include PaypalService::MerchantInjector

    # Include with_success for wrapping requests and responses
    include RequestWrapper

    attr_reader :logger

    MerchantData = PaypalService::DataTypes::Merchant
    TokenStore = PaypalService::Store::Token

    def initialize(logger = PaypalService::Logger.new)
      @logger = logger
    end

    # GET /billing_agreements/:community_id/:person_id
    def get_billing_agreement(community_id, person_id)
      raise NoMethodError.new("Not implemented")
    end


    # POST /billing_agreements/:community_id/:person_id/charge_commission
    def charge_commission(community_id, person_id, info)
      with_accounts(community_id, person_id) do |m_acc, admin_acc|
        with_completed_payment(community_id, info[:transaction_id]) do |payment|
          if(m_acc[:payer_id] == admin_acc[:payer_id])
            commission_not_applicable(community_id, info[:transaction_id], m_acc[:person_id], payment)
          else
            apply_commission(community_id, info, m_acc, admin_acc, payment)
          end
        end
      end
    end


    private

    def commission_not_applicable(community_id, transaction_id, merchant_id, payment)
      updated_payment = PaypalService::Store::PaypalPayment.update(
        community_id,
        transaction_id,
        payment.merge({
            commission_status: :not_applicable
          }))
      Result::Success.new(DataTypes.create_payment(updated_payment.merge({ merchant_id: merchant_id })))
    end

    def apply_commission(community_id, info, m_acc, admin_acc, payment)
      with_success(community_id, info[:transaction_id],
        MerchantData.create_do_reference_transaction({
            receiver_username: admin_acc[:email],
            billing_agreement_id: m_acc[:billing_agreement_id],
            payment_total: info[:commission_total],
            name: info[:payment_name],
            desc: info[:payment_desc] || info[:payment_name],
            invnum: "#{info[:transaction_id].to_s}-com"
          }),
        error_policy: {
          codes_to_retry: ["10001", "x-timeout", "x-servererror"],
          try_max: 5
        }
        ) do |ref_tx_res|              # Update payment
        updated_payment = PaypalService::Store::PaypalPayment.update(
          community_id,
          info[:transaction_id],
          payment.merge({
              commission_payment_id: ref_tx_res[:payment_id],
              commission_payment_date: ref_tx_res[:payment_date],
              commission_total: ref_tx_res[:payment_total],
              commission_fee_total: ref_tx_res[:fee],
              commission_status: ref_tx_res[:payment_status],
              commission_pending_reason: ref_tx_res[:pending_reason]
            }))              # Return as payment entity
        Result::Success.new(DataTypes.create_payment(updated_payment.merge({ merchant_id: m_acc[:person_id] })))
      end
    end

    def with_accounts(cid, pid, &block)
      admin_acc = PaypalService::PaypalAccount::Query.admin_account(cid)
      if admin_acc.nil?
        return Result::Error.new("No matching admin account for community_id: #{cid} and transaction_id: #{txid}.")
      end

      m_acc = PaypalService::PaypalAccount::Query.personal_account(pid, cid)
      if m_acc.nil?
        return Result::Error.new("Cannot find paypal account for the given community and person: community_id: #{cid}, person_id: #{pid}.")
      end

      block.call(m_acc, admin_acc)
    end

    def with_completed_payment(cid, txid, &block)
      payment = PaypalService::Store::PaypalPayment.get(cid, txid)
      if (payment.nil?)
        return Result::Error.new("No matching payment for community_id: #{cid} and transaction_id: #{txid}.")
      end

      if (payment[:payment_status] != :completed)
        return Result::Error.new("Payment is not in :completed state. State was: #{payment[:payment_status]}.")
      end

      if (payment[:commission_status] != :not_charged)
        return Result::Error.new("Commission already charged. Commission status was: #{payment[:commission_status]}")
      end

      block.call(payment)
    end

  end
end
