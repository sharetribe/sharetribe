
# Various helping methods to lookup context (from DB) for paypal operations

module PaypalService::API::Lookup

  TokenStore = PaypalService::Store::Token
  PaymentStore = PaypalService::Store::PaypalPayment


  module_function

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

end
