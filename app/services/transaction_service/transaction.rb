module TransactionService::Transaction

  class IllegalTransactionStateException < Exception
  end

  DataTypes = TransactionService::DataTypes::Transaction
  ProcessStatus = TransactionService::DataTypes::ProcessStatus

  TxStore = TransactionService::Store::Transaction
  ProcessTokenStore = TransactionService::Store::ProcessToken

  DEPRECATED_GATEWAYS = [:braintree, :checkout]

  SETTINGS_ADAPTERS = {
    paypal: TransactionService::Gateway::PaypalSettingsAdapter.new,
    stripe: TransactionService::Gateway::StripeSettingsAdapter.new,
    none: TransactionService::Gateway::FreeSettingsAdapter.new
  }

  GATEWAY_ADAPTERS = {
    paypal: TransactionService::Gateway::PaypalAdapter.new,
    stripe: TransactionService::Gateway::StripeAdapter.new,
    none: TransactionService::Gateway::FreeAdapter.new,
  }

  TX_PROCESSES = {
    preauthorize: TransactionService::Process::Preauthorize.new,
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


  # TODO should require community_id
  # TODO Return type should be Result (wraps current return type)
  # Deprecated
  def query(transaction_id)
    ActiveSupport::Deprecation.warn("TransactionService::Transaction.query: this is deprecated and will be removed in the near future.")

    Maybe(TxStore.get(transaction_id))
      .map { |tx| to_tx_response(tx) }
      .or_else(nil)
  end

  def get(community_id:, transaction_id:)
    Maybe(TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id))
      .map { |tx|  Result::Success.new(to_tx_response(tx)) }
      .or_else(Result::Error.new("No tx for community_id: #{community_id} and transaction_id: #{transaction_id}"))
  end

  def has_unfinished_transactions(person_id)
    TxStore.unfinished_tx_count(person_id) > 0
  end

  def can_start_transaction(opts)
    payment_gateway = opts[:transaction][:payment_gateway]
    author_id = opts[:transaction][:listing_author_id]
    community_id = opts[:transaction][:community_id]

    payment_gateways = payment_gateway.is_a?(Array) ? payment_gateway : [payment_gateway]
    payment_gateways.each do |gateway|
      set_adapter = settings_adapter(gateway)
      if set_adapter.configured?(community_id: community_id, author_id: author_id)
        return Result::Success.new(result: true)
      end
    end
    Result::Success.new(result: false)
  end

  def create(opts, force_sync: true)
    opts_tx = opts[:transaction]

    set_adapter = settings_adapter(opts_tx[:payment_gateway])
    tx_process_settings = set_adapter.tx_process_settings(opts_tx)

    tx = TxStore.create(opts_tx.merge(tx_process_settings))

    tx_process = tx_process(tx[:payment_process])
    gateway_adapter = gateway_adapter(tx[:payment_gateway])
    res = tx_process.create(tx: tx,
                            gateway_fields: opts[:gateway_fields],
                            gateway_adapter: gateway_adapter,
                            force_sync: force_sync)

    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
  end

  def finalize_create(community_id:, transaction_id:, force_sync: true)
    tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)

    # Try to find existing process token
    # This may happen if finalize_create action has been called already, for example
    # as a reaction to payment event
    proc_token = ProcessTokenStore.get_by_transaction(community_id: community_id,
                                                      transaction_id: transaction_id,
                                                      op_name: :do_finalize_create)

    res =
      if !force_sync && proc_token.present?
        proc_status_response(proc_token)
      elsif tx.nil?
        # Transaction doesn't exist.
        #
        # This may happen if the finalize_create action has been called already, and it failed.
        # If the finalization fails (e.g. booking fails), we void the payment and delete the
        # transaction.
        Result::Error.new("Can't find transaction, id: #{transaction_id}, community_id: #{community_id}", {code: :tx_not_existing})
      else
        tx_process = tx_process(tx[:payment_process])
        gw = gateway_adapter(tx[:payment_gateway])

        tx_process.finalize_create(
          tx: tx,
          gateway_adapter: gw,
          force_sync: force_sync)
      end

    res.and_then { |tx_fields|
      # Transaction may be nil, if it has been deleted due to voided payment
      m_tx = Maybe(tx)

      Result::Success.new(DataTypes.create_transaction_response(
                            m_tx.map { |tx_val| query(tx_val[:id]) }.or_else(nil),
                            {},
                            tx_fields))
    }
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

  def complete(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx[:payment_process])
    gw = gateway_adapter(tx[:payment_gateway])

    res = tx_process.complete(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(DataTypes.create_transaction_response(query(tx[:id]), gw_fields)) }
      .or_else(res)
  end

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

    if commission_to_admin.positive?
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

  def payment_details(tx)
    if DEPRECATED_GATEWAYS.include?(tx[:payment_gateway])
      ActiveSupport::Deprecation.warn(
        "Payment gateway adapter '#{tx[:payment_gateway]}' is deprecated.")

      { payment_total: nil,
        total_price: tx[:unit_price] * tx[:listing_quantity],
        charged_commission: nil,
        payment_gateway_fee: nil }
    else
      gw = gateway_adapter(tx[:payment_gateway])
      gw.get_payment_details(tx: tx)
    end
  end

  def to_tx_response(tx)
    item_total = tx[:unit_price] * tx[:listing_quantity]
    commission_total = calculate_commission(item_total, tx[:commission_from_seller], tx[:minimum_commission])

    payment = payment_details(tx)

    DataTypes.create_transaction(
      {
        id: tx[:id],
        payment_process: tx[:payment_process],
        payment_gateway: tx[:payment_gateway],
        community_id: tx[:community_id],
        community_uuid: tx[:community_uuid],
        starter_id: tx[:starter_id],
        listing_id: tx[:listing_id],
        listing_uuid: tx[:listing_uuid],
        listing_title: tx[:listing_title],
        listing_price: tx[:unit_price],
        unit_type: tx[:unit_type],
        unit_tr_key: tx[:unit_tr_key],
        unit_selector_tr_key: tx[:unit_selector_tr_key],
        availability: tx[:availability],
        item_total: item_total,
        shipping_price: tx[:shipping_price],
        listing_author_id: tx[:listing_author_id],
        listing_quantity: tx[:listing_quantity],
        automatic_confirmation_after_days: tx[:automatic_confirmation_after_days],
        last_transition_at: tx[:last_transition_at],
        current_state: tx[:current_state],
        payment_total: payment[:payment_total],
        minimum_commission: tx[:minimum_commission],
        commission_from_seller: tx[:commission_from_seller],
        checkout_total: payment[:total_price],
        commission_total: commission_total,
        charged_commission: payment[:charged_commission],
        payment_gateway_fee: payment[:payment_gateway_fee],
        shipping_address: tx[:shipping_address],
        booking: tx[:booking]})
  end

  def calculate_commission(item_total, commission_from_seller, minimum_commission)
    [(item_total * (commission_from_seller / 100.0) unless commission_from_seller.nil?),
     (minimum_commission unless minimum_commission.nil? || minimum_commission.zero?),
     Money.new(0, item_total.currency)]
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

  def proc_status_response(proc_token)
    Result::Success.new(
      ProcessStatus.create_process_status({
                                            process_token: proc_token[:process_token],
                                            completed: proc_token[:op_completed],
                                            result: proc_token[:op_output]}))
  end
end
