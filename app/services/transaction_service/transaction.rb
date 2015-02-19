module TransactionService::Transaction

  DataTypes = TransactionService::DataTypes::Transaction
  TransactionModel = ::Transaction

  PaymentSettingsStore = TransactionService::Store::PaymentSettings

  TxStore = TransactionService::Store::Transaction

  module_function

  def query(transaction_id)
    tx = TxStore.get(transaction_id)
    to_tx_response(tx)
  end

  def has_unfinished_transactions(person_id)
    finished_states = "'free', 'rejected', 'confirmed', 'canceled', 'errored'"

    unfinished = TransactionModel
                 .where("starter_id = ? OR listing_author_id = ?", person_id, person_id)
                 .where("current_state NOT IN (#{finished_states})")

    unfinished.length > 0
  end

  def can_start_transaction(opts)
    author_id = opts[:transaction][:listing_author_id]
    community_id = opts[:transaction][:community_id]

    result =
      case opts[:transaction][:payment_gateway]
      when :paypal
        can_start_transaction_paypal(community_id: community_id, author_id: author_id)
      when :braintree, :checkout
        can_start_transaction_braintree(community_id: community_id, author_id: author_id)
      when :none
        true
      else
        raise ArgumentError.new("Unknown payment gateway #{opts[:transaction][:payment_gateway]}")
      end

    Result::Success.new(result: result)
  end

  def can_start_transaction_braintree(community_id:, author_id:)
    Community.find(community_id).payment_gateway.can_receive_payments?(Person.find(author_id))
  end

  def can_start_transaction_paypal(community_id:, author_id:)
    payment_settings = Maybe(PaymentSettingsStore.get_active(community_id: community_id))
                       .select {|set| paypal_settings_configured?(set)}

    personal_account_verified = paypal_account_verified?(community_id: community_id, person_id: author_id, settings: payment_settings)
    community_account_verified = paypal_account_verified?(community_id: community_id)
    payment_settings_available = payment_settings.map {|_| true }.or_else(false)

    [personal_account_verified, community_account_verified, payment_settings_available].all?
  end

  def create(opts, paypal_async: false)
    opts_tx = opts[:transaction]

    #TODO this thing should come through transaction_opts
    minimum_commission, commission_from_seller, auto_confirm_days =
      case opts_tx[:payment_gateway]
      when :braintree
        tx_data_braintree(opts_tx)
      when :paypal
        tx_data_paypal(opts_tx)
      end

    tx = TxStore.create(
      opts_tx.merge({minimum_commission: minimum_commission,
                     commission_from_seller: commission_from_seller,
                     automatic_confirmation_after_days: auto_confirm_days}))

    gateway_fields_response =
      case [opts_tx[:payment_gateway], opts_tx[:payment_process]]
      when [:braintree, :preauthorize]
        create_tx_braintree(tx: tx, gateway_fields: opts[:gateway_fields], async: false)
      when [:paypal, :preauthorize]
        create_tx_paypal(tx: tx, gateway_fields: opts[:gateway_fields], async: paypal_async)
      else
        # Braintree Postpay (/ Other payment type?)
        Result::Success.new({})
      end

    if gateway_fields_response[:success]
      Result::Success.new(
        DataTypes.create_transaction_response(to_tx_response(tx), gateway_fields_response[:data]))
    else
      gateway_fields_respon
    end
  end

  # Private
  def tx_data_braintree(opts_tx)
    currency = opts_tx[:unit_price].currency
    c = Community.find(opts_tx[:community_id])

    [Money.new(0, currency), c.commission_from_seller, c.automatic_confirmation_after_days]
  end

  # Private
  def create_tx_braintree(tx:, gateway_fields:, async:)
    payment_gateway_id = BraintreePaymentGateway.where(community_id: tx[:community_id]).pluck(:id).first
    payment = BraintreePayment.create(
      {
        transaction_id: tx[:id],
        community_id: tx[:community_id],
        payment_gateway_id: payment_gateway_id,
        status: :pending,
        payer_id: tx[:starter_id],
        recipient_id: tx[:listing_author_id],
        currency: "USD",
        sum: tx[:unit_price] * tx[:listing_quantity]})

    result = BraintreeSaleService.new(payment, gateway_fields).pay(false)

    unless result.success?
      return Result::Error.new(result.message)
    end

    Result::Success.new({})
  end

  # Private
  def tx_data_paypal(opts_tx)
    currency = opts_tx[:unit_price].currency
    p_set = PaymentSettingsStore.get_active(community_id: opts_tx[:community_id])

    [Money.new(p_set[:minimum_transaction_fee_cents], currency),
     p_set[:commission_from_seller],
     p_set[:confirmation_after_days]]
  end

  # Private
  def create_tx_paypal(tx:, gateway_fields:, async:)
    # Note: Quantity may be confusing in Paypal Checkout page, thus, we don't use separated unit price and quantity,
    # only the total price.
    total = tx[:unit_price] * tx[:listing_quantity]

    create_payment_info = PaypalService::API::DataTypes.create_create_payment_request({
      transaction_id: tx[:id],
      item_name: tx[:listing_title],
      item_quantity: 1,
      item_price: total,
      merchant_id: tx[:listing_author_id],
      order_total: total,
      success: gateway_fields[:success_url],
      cancel: gateway_fields[:cancel_url],
      merchant_brand_logo_url: gateway_fields[:merchant_brand_logo_url]})

    result = PaypalService::API::Api.payments.request(
      tx[:community_id],
      create_payment_info,
      async: async)

    return Result::Error.new(result[:error_msg]) unless result[:success]

    if async
      Result::Success.new({ process_token: result[:data][:process_token] })
    else
      Result::Success.new({ redirect_url: result[:data][:redirect_url] })
    end
  end

  def reject(community_id, transaction_id)
    payment_type = TransactionModel.where(id: transaction_id, community_id: community_id).pluck(:payment_gateway).first

    case(payment_type)
    when "braintree"
      BraintreeService::Payments::Command.void_transaction(transaction_id, community_id)
      #TODO: Event handling also to braintree service?
      MarketplaceService::Transaction::Command.transition_to(transaction_id, "rejected")

      transaction = query(transaction_id)
      Result::Success.new(DataTypes.create_transaction_response(transaction))
    when "paypal"
      result = paypal_payment_api.void(community_id, transaction_id, {note: ""})
      if result[:success]
        transaction = query(transaction_id)
        Result::Success.new(DataTypes.create_transaction_response(transaction))
      else
        result
      end
    end
  end


  def complete_preauthorization(transaction_id)
    transaction = MarketplaceService::Transaction::Query.transaction(transaction_id)

    case transaction[:payment_gateway].to_sym
    when :braintree
      complete_preauthorization_braintree(transaction)
    when :paypal
      complete_preauthorization_paypal(transaction)
    end

  end

  def complete_preauthorization_braintree(transaction)
    BraintreeService::Payments::Command.submit_to_settlement(transaction[:id], transaction[:community_id])
    MarketplaceService::Transaction::Command.transition_to(transaction[:id], :paid)

    transaction = query(transaction[:id])
    Result::Success.new(DataTypes.create_transaction_response(transaction))
  end

  def complete_preauthorization_paypal(transaction)
    paypal_payments = paypal_payment_api
    payment_response = paypal_payments.get_payment(transaction[:community_id], transaction[:id])

    if payment_response[:success]
      payment = payment_response[:data]
      capture_response = paypal_payments.full_capture(
        transaction[:community_id],
        transaction[:id],
        PaypalService::API::DataTypes.create_payment_info({ payment_total: payment[:authorization_total] }))

      if capture_response[:success]
        Result::Success.new(
          DataTypes.create_transaction_response(
            transaction,
            DataTypes.create_paypal_complete_preauthorization_fields(paypal_pending_reason: capture_response[:data][:pending_reason])))
      else
        Result::Error.new("An error occured while trying to complete preauthorized PayPal payment")
      end
    else
      Result::Error.new("No payment found for community_id: #{transaction[:community_id]} and transaction_id: #{transaction[:id]}")
    end
  end


  def invoice
    raise NoMethodError.new("Not implemented")
  end

  def pay_invoice
    raise NoMethodError.new("Not implemented")
  end

  def complete(transaction_id)
    MarketplaceService::Transaction::Command.transition_to(transaction_id, :confirmed)

    transaction = query(transaction_id)
    MarketplaceService::Transaction::Command.mark_as_unseen_by_other(transaction_id, transaction[:listing_author_id])

    Result::Success.new(DataTypes.create_transaction_response(transaction))
  end

  def cancel(transaction_id)
    MarketplaceService::Transaction::Command.transition_to(transaction_id, :canceled)

    transaction = query(transaction_id)
    MarketplaceService::Transaction::Command.mark_as_unseen_by_other(transaction_id,transaction[:listing_author_id])

    Result::Success.new(DataTypes.create_transaction_response(transaction))
  end

  def token_cancelled(token)
    Transaction.where(community_id: token[:community_id], id: token[:transaction_id]).destroy_all
  end

  # private

  def charge_commission(transaction_id)
    transaction = query(transaction_id)
    payment = paypal_payment_api.get_payment(transaction[:community_id], transaction[:id])[:data]
    commission_to_admin = calculate_commission_to_admin(transaction[:commission_total], payment[:payment_total], payment[:fee_total])

    if (commission_to_admin.positive?)
      charge_request =
        {
          transaction_id: transaction_id,
          payment_name: I18n.translate_with_service_name("paypal.transaction.commission_payment_name", { listing_title: transaction[:listing_title] }),
          payment_desc: I18n.translate_with_service_name("paypal.transaction.commission_payment_description", { listing_title: transaction[:listing_title] }),
          minimum_commission: transaction[:minimum_commission],
          commission_to_admin: commission_to_admin
        }

      paypal_billing_agreement_api().charge_commission(transaction[:community_id], transaction[:listing_author_id], charge_request)
    else
      Result::Success.new({})
    end
  end

  def to_tx_response(tx)
    checkout_details = checkout_details(tx)
    commission_total = calculate_commission(checkout_details[:total_price], tx[:commission_from_seller], tx[:minimum_commission])

    DataTypes.create_transaction(
      {
        id: tx[:id],
        payment_process: tx[:payment_process],
        payment_gateway: tx[:payment_gateway],
        community_id: tx[:community_id],
        starter_id: tx[:starter_id],
        listing_id: tx[:listing_id],
        listing_title: tx[:listing_title],
        listing_price: tx[:unit_price],
        listing_author_id: tx[:listing_author_id],
        listing_quantity: tx[:listing_quantity],
        automatic_confirmation_after_days: tx[:automatic_confirmation_after_days],
        last_transition_at: tx[:last_transition_at],
        current_state: tx[:current_state],
        payment_total: checkout_details[:payment_total],
        minimum_commission: tx[:minimum_commission],
        commission_from_seller: tx[:commission_from_seller],
        checkout_total: checkout_details[:total_price],
        commission_total: commission_total,
        charged_commission: checkout_details[:charged_commission],
        payment_gateway_fee: checkout_details[:payment_gateway_fee]})
  end

  def checkout_details(tx)
    case tx[:payment_gateway]
    when :checkout, :braintree
      payment_total = Maybe(Payment.where(transaction_id: tx[:id]).first).total_sum.or_else(nil)
      total_price = tx[:unit_price] * 1 # TODO fixme for booking (model.listing_quantity)
      { payment_total: payment_total,
        total_price: total_price }
    when :paypal
      payment = paypal_payment_api().get_payment(tx[:community_id], tx[:id]).maybe
      payment_total = payment[:payment_total].or_else(nil)
      total_price = Maybe(payment[:payment_total].or_else(payment[:authorization_total].or_else(nil)))
              .or_else(tx[:unit_price])
      { payment_total: payment_total,
        total_price: total_price,
        charged_commission: payment[:commission_total].or_else(nil),
        payment_gateway_fee: payment[:fee_total].or_else(nil) }
    end
  end

  def calculate_commission(total_price, commission_from_seller, minimum_commission)
    [(total_price * (commission_from_seller / 100.0) unless commission_from_seller.nil?),
     (minimum_commission unless minimum_commission.nil? || minimum_commission.zero? ),
     Money.new(0, total_price.currency)]
      .compact
      .max
  end

  def calculate_commission_to_admin(commission_total, payment_total, fee_total)
    # Ensure we never charge more than what the seller received after payment processing fee
    [commission_total, payment_total - fee_total].min
  end

  def paypal_settings_configured?(settings)
    settings[:payment_gateway] == :paypal && !!settings[:commission_from_seller] && !!settings[:minimum_price_cents]
  end

  def paypal_account_verified?(community_id:, person_id: nil, settings: Maybe(nil))
    acc_state = paypal_accounts_api.get(community_id: community_id, person_id: person_id).maybe()[:state].or_else(:not_connected)
    commission_type = settings[:commission_type].or_else(nil)

    acc_state == :verified || (acc_state == :connected && commission_type == :none)
  end

  def paypal_payment_api
    PaypalService::API::Api.payments
  end

  def paypal_billing_agreement_api
    PaypalService::API::Api.billing_agreements
  end

  def paypal_accounts_api
    PaypalService::API::Api.accounts_api
  end
end
