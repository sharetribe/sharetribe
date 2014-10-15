module TransactionService::Transaction

  module Entity
    Transaction = EntityUtils.define_builder(
      [:payment_process, one_of: [:none, :postpay, :preauthorize]],
      [:payment_gateway, one_of: [:paypal, :checkout, :braintree, nil]],
      [:community_id, :fixnum, :mandatory],
      [:starter_id, :string, :mandatory],
      [:listing_id, :fixnum, :mandatory],
      [:listing_title, :string, :mandatory],
      [:listing_price, :money, :optional],
      [:listing_author_id, :string, :mandatory],
      [:listing_quantity, :fixnum, default: 1],
      [:automatic_confirmation_after_days, :fixnum],
      [:last_transition_at, :time],
      [:current_state, :symbol])

    module_function

    def transaction(model)
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

      Transaction.call({
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

  DataTypes = TransactionService::DataTypes::Transaction

  module_function

  def query(transaction_id)
    Entity.transaction(Transaction.find(transaction_id))
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
      paypal_account = PaypalService::PaypalAccount::Query.personal_account(transaction[:listing][:author_id], transaction[:community_id])
      paypal_payment = PaypalService::PaypalPayment::Query.for_transaction(transaction[:id])

      api_params = {
        receiver_username: paypal_account[:email],
        authorization_id: paypal_payment[:authorization_id],
        payment_total: paypal_payment[:authorization_total]
      }

      merchant = PaypalService::MerchantInjector.build_paypal_merchant
      capture_request = PaypalService::DataTypes::Merchant.create_do_full_capture(api_params)
      capture_response = merchant.do_request(capture_request)

      if capture_response[:success]
        PaypalService::PaypalPayment::Command.update(paypal_payment.merge(capture_response))

        if capture_response[:payment_status] != "completed"
          MarketplaceService::Transaction::Command.transition_to(transaction[:id], :pending_ext)
          transaction = query(transaction[:id])
          Result::Success.new(
            DataTypes.create_transaction_response(transaction, DataTypes.create_paypal_complete_preauthorization_fields(pending_reason: capture_response[:pending_reason])))
        else
          MarketplaceService::Transaction::Command.transition_to(transaction[:id], :paid)
          transaction = query(transaction[:id])
          Result::Success.new(
            DataTypes.create_transaction_response(transaction))
        end
      else
        Result::Error.new("An error occured while trying to complete preauthorized Paypal payment")
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
end
