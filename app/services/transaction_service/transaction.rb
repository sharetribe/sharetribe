module TransactionService::Transaction

  DataTypes = TransactionService::DataTypes::Transaction

  module_function

  def query(transaction_id)
    model_to_entity(Transaction.find(transaction_id))
  end

  def create
    raise "Not implemented"
  end

  def preauthorize
    raise "Not implemented"
  end

  def reject
    raise "Not implemented"
  end

  def complete_preauthorization(transaction_id)
    transaction = MarketplaceService::Transaction::Query.transaction(transaction_id)
    payment_type = MarketplaceService::Community::Query.payment_type(transaction[:community_id])

    case payment_type
    when :braintree
      BraintreeService::Payments::Command.submit_to_settlement(transaction[:id], transaction[:community_id])
      MarketplaceService::Transaction::Command.transition_to(transaction[:id], :paid)

      transaction = query(transaction[:id])

      Result::Success.new(
        DataTypes.create_transaction_response(transaction))
    when :paypal
      paypal_payments = PaypalService::API::Payments.new

      payment_response = paypal_payments.get_payment(transaction[:community_id], transaction[:id])
      if payment_response[:success]
        payment = payment_response[:data]
        capture_response = paypal_payments.full_capture(
          transaction[:community_id],
          transaction[:id],
          PaypalService::API::DataTypes.create_payment_info({ payment_total: payment[:authorization_total] }))

        if capture_response[:success]
          next_state =
            if capture_response[:data][:payment_status] == :completed
              :paid
            else
              :pending_ext
            end

          MarketplaceService::Transaction::Command.transition_to(transaction[:id], next_state, pending_reason: capture_response[:data][:pending_reason])

          transaction = query(transaction[:id])
          Result::Success.new(
            DataTypes.create_transaction_response(transaction, DataTypes.create_paypal_complete_preauthorization_fields(pending_reason: capture_response[:data][:pending_reason])))
        else
          Result::Error.new("An error occured while trying to complete preauthorized Paypal payment")
        end
      end

    end
  end

  def invoice
    raise "Not implemented"
  end

  def pay_invoice
    raise "Not implemented"
  end

  def complete
    raise "Not implemented"
  end

  def cancel
    raise "Not implemented"
  end

  # private

  # Warning!
  # This is only an intermediate solution. Ideally, we would store all the required
  # transaction data in transaction service, but now we have to fetch the data from here and there.
  # However, this method is only used to get the API interface right, even though the data model
  # doesn't match the interface.
  #
  def model_to_entity(model)
    payment_process =
      if !model.listing.transaction_type.price_field?
        :none
      else
        if model.listing.transaction_type.preauthorize_payment?
          :preauthorize
        else
          :postpay
        end
      end

    payment_gateway = MarketplaceService::Community::Query.payment_type(model.community_id)

    DataTypes.create_transaction({
        payment_process: payment_process,
        payment_gateway: payment_gateway,
        community_id: model.community_id,
        starter_id: model.starter.id,
        listing_id: model.listing.id,
        listing_title: model.listing.title,
        listing_price: model.listing.price,
        listing_author_id: model.listing.author.id,
        listing_quantity: 1,
        automatic_confirmation_after_days: model.automatic_confirmation_after_days,
        last_transition_at: model.last_transition_at,
        current_state: model.current_state.to_sym})
  end
end
