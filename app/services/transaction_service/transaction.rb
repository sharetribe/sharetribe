module TransactionService::Transaction

  class IllegalTransactionStateException < Exception
  end

  ProcessStatus = TransactionService::DataTypes::ProcessStatus

  TxStore = TransactionService::Store::Transaction
  ProcessTokenStore = TransactionService::Store::ProcessToken
  TxModel = ::Transaction

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

  TransactionResponse = EntityUtils.define_builder(
    [:transaction, :optional],
    [:gateway_fields, :hash, :optional],
    [:transaction_service_fields, :hash, :optional])

  module_function

  def authorization_expiration_period(payment_type)
    # TODO These configs should be moved to Paypal services
    case payment_type
    when :paypal
      APP_CONFIG.paypal_expiration_period.to_i
    when :stripe
      APP_CONFIG.stripe_expiration_period.to_i
    else
      raise ArgumentError.new("Unknown payment_type: '#{payment_type}'")
    end
  end

  # Params:
  # - gateway_expires_at (how long the payment authorization is valid)
  # - max_date_at (max date, e.g. booking ending)
  def preauth_expires_at(gateway_expires_at, max_date_at=nil)
    [
      gateway_expires_at.in_time_zone,
      Maybe(max_date_at).map {|d| (d + 2.days).in_time_zone}.or_else(nil)
    ].compact.min
  end

  def create_transaction_response(transaction, gateway_fields = {}, transaction_service_fields = {})
    {
      transaction: transaction,
      gateway_fields: gateway_fields,
      transaction_service_fields: transaction_service_fields
    }
  end

  def settings_adapter(payment_gateway)
    adapter = SETTINGS_ADAPTERS[payment_gateway.to_sym]
    raise ArgumentError.new("No matching settings adapter found for payment_gateway type #{payment_gateway}.") if adapter.nil?

    adapter
  end

  def tx_process(payment_process)
    tx_process = TX_PROCESSES[payment_process.to_sym]
    raise ArgumentError.new("No matching tx process handler found for #{payment_process}.") if tx_process.nil?

    tx_process
  end

  def gateway_adapter(payment_gateway)
    adapter = GATEWAY_ADAPTERS[payment_gateway.to_sym]
    raise ArgumentError.new("No matching gateway adapter found for payment_gateway type #{payment_gateway}.") if adapter.nil?

    adapter
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
    opts_tx = opts[:transaction].to_hash

    set_adapter = settings_adapter(opts_tx[:payment_gateway])
    tx_process_settings = set_adapter.tx_process_settings(opts_tx)

    tx = TxStore.create(opts_tx.merge(tx_process_settings))

    tx_process = tx_process(tx[:payment_process])
    gateway_adapter = gateway_adapter(tx[:payment_gateway])
    res = tx_process.create(tx: tx,
                            gateway_fields: opts[:gateway_fields],
                            gateway_adapter: gateway_adapter,
                            force_sync: force_sync)

    tx.reload
    res.maybe()
      .map { |gw_fields| Result::Success.new(create_transaction_response(tx, gw_fields)) }
      .or_else(res)
  end

  def find_tx_model(community_id:, transaction_id:)
    TxModel.where(community_id: community_id, id: transaction_id).first
  end

  def finalize_create(community_id:, transaction_id:, force_sync: true)
    tx = find_tx_model(community_id: community_id, transaction_id: transaction_id)

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
        tx_process = tx_process(tx.payment_process)
        gw = gateway_adapter(tx.payment_gateway)

        tx_process.finalize_create(
          tx: tx,
          gateway_adapter: gw,
          force_sync: force_sync)
      end

    res.and_then { |tx_fields|
      Result::Success.new(create_transaction_response(tx, {}, tx_fields))
    }
  end

  def reject(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = find_tx_model(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx.payment_process)
    gw = gateway_adapter(tx.payment_gateway)

    res = tx_process.reject(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(create_transaction_response(tx, gw_fields)) }
      .or_else(res)
  end


  def complete_preauthorization(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = find_tx_model(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx.payment_process)
    gw = gateway_adapter(tx.payment_gateway)

    res = tx_process.complete_preauthorization(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(create_transaction_response(tx, gw_fields)) }
      .or_else(res)
  end

  def complete(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = find_tx_model(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx.payment_process)
    gw = gateway_adapter(tx.payment_gateway)

    res = tx_process.complete(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(create_transaction_response(tx, gw_fields)) }
      .or_else(res)
  end

  def cancel(community_id:, transaction_id:, message: nil, sender_id: nil)
    tx = find_tx_model(community_id: community_id, transaction_id: transaction_id)

    tx_process = tx_process(tx.payment_process)
    gw = gateway_adapter(tx.payment_gateway)

    res = tx_process.cancel(tx: tx, message: message, sender_id: sender_id, gateway_adapter: gw)
    res.maybe()
      .map { |gw_fields| Result::Success.new(create_transaction_response(tx, gw_fields)) }
      .or_else(res)
  end

  # private

  def charge_commission(transaction_id)
    transaction = Transaction.find(transaction_id)
    payment = paypal_payment_api.get_payment(transaction.community_id, transaction.id)[:data]
    commission_to_admin = calculate_commission_to_admin(transaction.commission, payment[:payment_total], payment[:fee_total])

    if commission_to_admin.positive?
      charge_request =
        {
          transaction_id: transaction_id,
          payment_name: I18n.translate_with_service_name("paypal.transaction.commission_payment_name", { listing_title: transaction.listing_title }),
          payment_desc: I18n.translate_with_service_name("paypal.transaction.commission_payment_description", { listing_title: transaction.listing_title }),
          minimum_commission: transaction.minimum_commission,
          commission_to_admin: commission_to_admin
        }

      paypal_billing_agreement_api().charge_commission(transaction.community_id, transaction.listing_author_id, charge_request)
    else
      Result::Success.new({})
    end
  end

  def payment_details(tx)
    if DEPRECATED_GATEWAYS.include?(tx.payment_gateway)
      ActiveSupport::Deprecation.warn(
        "Payment gateway adapter '#{tx.payment_gateway}' is deprecated.")

      { payment_total: nil,
        total_price: tx.unit_price * tx.listing_quantity,
        charged_commission: nil,
        payment_gateway_fee: nil }
    else
      gw = gateway_adapter(tx.payment_gateway)
      gw.get_payment_details(tx: tx)
    end
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
