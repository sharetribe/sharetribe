module TransactionService::Transaction

  DataTypes = TransactionService::DataTypes::Transaction

  TxStore = TransactionService::Store::Transaction

  SETTINGS_ADAPTERS = {
    paypal: TransactionService::Gateway::PaypalSettingsAdapter.new,
    braintree: TransactionService::Gateway::BraintreeSettingsAdapter.new,
    checkout: TransactionService::Gateway::BraintreeSettingsAdapter.new, # Checkout handles configuration the same way as BT
    none: TransactionService::Gateway::FreeSettingsAdapter.new
  }

  GATEWAY_ADAPTERS = {
    paypal: TransactionService::Gateway::PaypalAdapter.new,
    braintree: TransactionService::Gateway::BraintreeAdapter.new,
    checkout: TransactionService::Gateway::CheckoutAdapter.new,
    none: TransactionService::Gateway::FreeAdapter.new
  }

  TX_PROCESSES = {
    preauthorize: TransactionService::Process::Preauthorize.new,
    postpay: TransactionService::Process::Postpay.new,
    none: TransactionService::Process::Free.new
  }

  module_function

  def settings_adapter(payment_gateway)
    adapter = SETTINGS_ADAPTERS[payment_gateway]
    raise ArgumentError.new("No matching settings adapter found for payment_gateway type #{payment_gateway}.") if adapter.nil?

    adapter
  end

  def tx_process(payment_process)
    tx_process = TX_PROCESSES[payment_process]
    raise ArgumentError.new("No matching tx process handler found for #{payment_process}.") if tx_process.nil?

    tx_process
  end

  def gateway_adapter(payment_gateway)
    adapter = GATEWAY_ADAPTERS[payment_gateway]
    raise ArgumentError.new("No matching gateway adapter found for payment_gateway type #{payment_gateway}.") if adapter.nil?

    adapter
  end


  # TODO Return type should be Result (wraps current return type)
  def query(transaction_id)
    tx = TxStore.get(transaction_id)
    to_tx_response(tx)
  end

  def has_unfinished_transactions(person_id)
    TxStore.unfinished_tx_count(person_id) > 0
  end

  def can_start_transaction(opts)
    payment_gateway = opts[:transaction][:payment_gateway]
    author_id = opts[:transaction][:listing_author_id]
    community_id = opts[:transaction][:community_id]

    set_adapter = settings_adapter(payment_gateway)

    Result::Success.new(result: set_adapter.configured?(community_id: community_id, author_id: author_id))
  end

  def create(opts, paypal_async: false)
    opts_tx = opts[:transaction]

    set_adapter = settings_adapter(opts_tx[:payment_gateway])
    tx_process_settings = set_adapter.tx_process_settings(opts_tx)

    tx = TxStore.create(opts_tx.merge(tx_process_settings))

    tx_process = tx_process(tx[:payment_process])
    gateway_adapter = gateway_adapter(tx[:payment_gateway])
    res = tx_process.create(tx: tx,
                            gateway_fields: opts[:gateway_fields],
                            gateway_adapter: gateway_adapter,
                            prefer_async: paypal_async)

    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
  end


  def reject(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx[:payment_process])
    gw = gateway_adapter(tx[:payment_gateway])

    res = tx_process.reject(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
  end


  def complete_preauthorization(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx[:payment_process])
    gw = gateway_adapter(tx[:payment_gateway])

    res = tx_process.complete_preauthorization(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
  end

  def invoice
    raise NoMethodError.new("Not implemented")
  end

  def pay_invoice
    raise NoMethodError.new("Not implemented")
  end

  # TODO Should handle optional message
  def complete(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx[:payment_process])
    gw = gateway_adapter(tx[:payment_gateway])

    res = tx_process.complete(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
  end

  # TODO Should handle optional message
  def cancel(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx[:payment_process])
    gw = gateway_adapter(tx[:payment_gateway])

    res = tx_process.cancel(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
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
    gw = gateway_adapter(tx[:payment_gateway])
    payment_details = gw.get_payment_details(tx: tx)

    commission_total = calculate_commission(payment_details[:total_price], tx[:commission_from_seller], tx[:minimum_commission])

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
        payment_total: payment_details[:payment_total],
        minimum_commission: tx[:minimum_commission],
        commission_from_seller: tx[:commission_from_seller],
        checkout_total: payment_details[:total_price],
        commission_total: commission_total,
        charged_commission: payment_details[:charged_commission],
        payment_gateway_fee: payment_details[:payment_gateway_fee]})
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

  def paypal_payment_api
    PaypalService::API::Api.payments
  end

  def paypal_billing_agreement_api
    PaypalService::API::Api.billing_agreements
  end
end
