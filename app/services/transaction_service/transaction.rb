module TransactionService::Transaction

  DataTypes = TransactionService::DataTypes::Transaction
  TransactionModel = ::Transaction

  PaymentSettingsStore = TransactionService::Store::PaymentSettings

  TxUtil = TransactionService::Util

  module_function

  def query(transaction_id)
    model_to_entity(TransactionModel.find(transaction_id))
  end

  def has_unfinished_transactions(person_id)
    finished_states = "'free', 'rejected', 'confirmed', 'canceled', 'errored'"

    unfinished = TransactionModel
                 .joins(:listing)
                 .where("starter_id = ? OR listings.author_id = ?", person_id, person_id)
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
    listing = Listing.find(opts_tx[:listing_id])
    minimum_commission, commission_from_seller, auto_confirm_days =
      case opts_tx[:payment_gateway]
      when :braintree
        tx_data_braintree(listing, opts_tx)
      when :paypal
        tx_data_paypal(listing, opts_tx)
      end

    transaction = TxUtil.create_tx_model_with_conversation(
      opts_tx.merge({minimum_commission: minimum_commission,
                     commission_from_seller: commission_from_seller,
                     automatic_confirmation_after_days: auto_confirm_days}))

    gateway_fields_response =
      case [opts_tx[:payment_gateway], opts_tx[:payment_process]]
      when [:braintree, :preauthorize]
        create_tx_braintree(transaction: transaction, listing: listing, opts: opts, async: false)
      when [:paypal, :preauthorize]
        create_tx_paypal(transaction: transaction, listing: listing, opts: opts, async: paypal_async)
      else
        # Braintree Postpay (/ Other payment type?)
        Result::Success.new({})
      end

    if gateway_fields_response[:success]
      transaction.save!
      #TODO: Fix to more sustainable solution (use model_to_entity, and add paypal and braintree relevant fields)
      #transition info is now added in controllers
      Result::Success.new(
        DataTypes.create_transaction_response(opts_tx.merge({
          id: transaction.id,
          created_at: transaction.created_at,
          updated_at: transaction.updated_at
        }),
        gateway_fields_response[:data]))
    else
      gateway_fields_response
    end

  end

  # Private
  def tx_data_braintree(listing, opts_tx)
    currency = listing.price.currency
    c = Community.find(opts_tx[:community_id])

    [Money.new(0, currency), c.commission_from_seller, c.automatic_confirmation_after_days]
  end

  # Private
  def create_tx_braintree(transaction:, listing:, opts:, async:)
    payment_gateway_id = BraintreePaymentGateway.where(community_id: opts[:transaction][:community_id]).pluck(:id).first
    transaction.payment = BraintreePayment.new({
      community_id: opts[:transaction][:community_id],
      payment_gateway_id: payment_gateway_id,
      status: "pending",
      payer_id: opts[:transaction][:starter_id],
      recipient_id: opts[:transaction][:listing_author_id],
      currency: "USD",
      sum: listing.price * transaction.listing_quantity})

    result = BraintreeSaleService.new(transaction.payment, opts[:gateway_fields]).pay(false)

    unless result.success?
      return Result::Error.new(result.message)
    end

    Result::Success.new({})
  end

  # Private
  def tx_data_paypal(listing, opts_tx)
    currency = listing.price.currency
    p_set = PaymentSettingsStore.get_active(community_id: opts_tx[:community_id])

    [Money.new(p_set[:minimum_transaction_fee_cents], currency),
     p_set[:commission_from_seller],
     p_set[:confirmation_after_days]]
  end

  # Private
  def create_tx_paypal(transaction:, listing:, opts:, async:)
    # Note: Quantity may be confusing in Paypal Checkout page, thus, we don't use separated unit price and quantity,
    # only the total price.
    quantity = 1
    total = listing.price * transaction.listing_quantity

    create_payment_info = PaypalService::API::DataTypes.create_create_payment_request({
      transaction_id: transaction.id,
      item_name: listing.title,
      item_quantity: quantity,
      item_price: total,
      merchant_id: opts[:transaction][:listing_author_id],
      order_total: total,
      success: opts[:gateway_fields][:success_url],
      cancel: opts[:gateway_fields][:cancel_url],
      merchant_brand_logo_url: opts[:gateway_fields][:merchant_brand_logo_url]})

    result = PaypalService::API::Api.payments.request(
      opts[:transaction][:community_id],
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

  # Warning!
  # This is only an intermediate solution. Ideally, we would store all the required
  # transaction data in transaction service, but now we have to fetch the data from here and there.
  # However, this method is only used to get the API interface right, even though the data model
  # doesn't match the interface.
  #
  def model_to_entity(model)
    payment_total =
      case model.payment_gateway.to_sym
      when :checkout, :braintree
        Maybe(model).payment.total_sum.or_else(nil)
      when :paypal
        payment = paypal_payment_api().get_payment(model.community_id, model.id)
        Maybe(payment).select { |p| p[:success] }[:data][:payment_total].or_else(nil)
      end

    checkout_details = checkout_details(model)
    DataTypes.create_transaction({
        id: model.id,
        payment_process: model.payment_process.to_sym,
        payment_gateway: model.payment_gateway.to_sym,
        community_id: model.community_id,
        starter_id: model.starter.id,
        listing_id: model.listing.id,
        listing_title: model.listing.title,
        listing_price: model.listing.price,
        listing_author_id: model.listing.author.id,
        listing_quantity: model.listing_quantity,
        automatic_confirmation_after_days: model.automatic_confirmation_after_days,
        last_transition_at: model.last_transition_at,
        current_state: model.current_state.to_sym,
        payment_total: payment_total,
        minimum_commission: model.minimum_commission,
        commission_from_seller: Maybe(model.commission_from_seller).or_else(0),
        checkout_total:   checkout_details[:total_price],
        commission_total: checkout_details[:commission_total],
        charged_commission: checkout_details[:charged_commission],
        payment_gateway_fee: checkout_details[:payment_gateway_fee]})
  end

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

  def checkout_details(model)

    case model.payment_gateway.to_sym
    when :paypal
      payment = paypal_payment_api().get_payment(model.community.id, model.id).maybe
      total = Maybe(payment[:payment_total].or_else(payment[:authorization_total].or_else(nil)))
              .or_else(model.listing.price)
      { total_price: total,
        commission_total: calculate_commission(total, model.commission_from_seller, model.minimum_commission),
        charged_commission: payment[:commission_total].or_else(nil),
        payment_gateway_fee: payment[:fee_total].or_else(nil) }
    else
      total = model.listing.price * 1 #TODO fixme for booking (model.listing_quantity)
      { total_price: total, commission_total: calculate_commission(total, model.commission_from_seller, model.minimum_commission) }
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
