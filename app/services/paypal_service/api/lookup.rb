
# Various helping methods to lookup context (from DB) for paypal operations

module PaypalService::API
  class Lookup

    TokenStore = PaypalService::Store::Token
    PaymentStore = PaypalService::Store::PaypalPayment
    AccountStore = PaypalService::Store::PaypalAccount

    def initialize(logger)
      @logger = logger
    end

    def with_active_account(cid, pid, &block)
      m_acc = AccountStore.get_active(person_id: pid, community_id: cid)
      if m_acc.nil?
        return log_and_return(Result::Error.new("Cannot find paypal account for the given community and person: community_id: #{cid}, person_id: #{pid}."))
      else
        block.call(m_acc)
      end
    end

    def with_accounts(cid, pid, receiver_id, &block)
      admin_acc = AccountStore.get_active(community_id: cid)
      if admin_acc.nil?
        return log_and_return(Result::Error.new("No matching admin account for community_id: #{cid}."))
      end

      m_acc = AccountStore.get(person_id: pid, community_id: cid, payer_id: receiver_id)
      if m_acc.nil?
        return log_and_return(Result::Error.new("Cannot find paypal account for the given community and person: community_id: #{cid}, person_id: #{pid}, payer_id: #{receiver_id}."))
      elsif m_acc[:billing_agreement_state] != :verified
        return log_and_return(Result::Error.new("Merchant account has no billing agreement setup."))
      end

      block.call(m_acc, admin_acc)
    end


    def with_token(cid, t, &block)
      token = TokenStore.get(cid, t)
      if (token.nil?)
        return log_and_return(Result::Error.new("No matching token for community_id: #{cid} and token: #{t}"))
      end

      block.call(token)
    end

    def with_merchant_account(cid, token, &block)
      m_acc = AccountStore.get(
        person_id: token[:merchant_id],
        community_id: cid,
        payer_id: token[:receiver_id]
      )
      if m_acc.nil?
        return log_and_return(Result::Error.new("No matching merchant account for community_id: #{cid} and person_id: #{token[:merchant_id]}."))
      end

      block.call(m_acc)
    end

    def with_payment(cid, txid, accepted_states = [], &block)
      payment = PaymentStore.get(cid, txid)

      if (payment.nil?)
        return log_and_return(Result::Error.new("No matching payment for community_id: #{cid} and transaction_id: #{txid}."))
      end

      if (!payment_in_accepted_state?(payment, accepted_states))
        return log_and_return(Result::Error.new("Payment was not in accepted precondition state for the requested operation. Expected one of: #{accepted_states}, was: :[#{payment[:payment_status]}, :#{payment[:pending_reason]}]"))
      end

      m_acc = AccountStore.get(person_id: payment[:merchant_id], community_id: cid, payer_id: payment[:receiver_id])
      if m_acc.nil?
        return log_and_return(Result::Error.new("No matching merchant account for community_id: #{cid} and transaction_id: #{txid}."))
      end

      block.call(payment, m_acc)
    end

    def with_completed_payment(cid, txid, &block)
      payment = PaypalService::Store::PaypalPayment.get(cid, txid)
      if (payment.nil?)
        return log_and_return(Result::Error.new("No matching payment for community_id: #{cid} and transaction_id: #{txid}."))
      end

      if (payment[:payment_status] != :completed)
        return log_and_return(Result::Error.new("Payment is not in :completed state. State was: #{payment[:payment_status]}."))
      end

      unless ([:not_charged, :errored].include?(payment[:commission_status]))
        return log_and_return(Result::Error.new("Commission already charged. Commission status was: #{payment[:commission_status]}"))
      end

      block.call(payment)
    end


    def get_payment_by_token(token)
      PaymentStore.get(token[:community_id], token[:transaction_id])
    end


    # Privates

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

    def log_and_return(err_response)
      @logger.warn(err_response[:error_msg])
      return err_response
    end

  end
end
