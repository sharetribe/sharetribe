module TransactionService::Transaction

  DataTypes = TransactionService::DataTypes::Transaction
  TransactionModel = ::Transaction

  module_function

  def query(transaction_id)
    model_to_entity(TransactionModel.find(transaction_id))
  end

  def can_start_transaction(opts)
    transaction_opts = opts[:transaction]
    author_id = transaction_opts[:listing_author_id]
    community_id = transaction_opts[:community_id]

    result =
      case transaction_opts[:payment_gateway]
      when :paypal
        paypal_account = PaypalService::PaypalAccount::Query.personal_account(author_id, community_id)
        PaypalService::PaypalAccount::Entity.paypal_account_prepared?(paypal_account)
      when :braintree
        Community.find(community_id).payment_gateway.can_receive_payments?(Person.find(author_id))
      when :checkout
        # TODO Implement
        true
      when :none
        true
      else
        raise "Unknown payment gateway #{payment_gateway}"
      end

    Result::Success.new(result: result)
  end

  def create(transaction_opts)
    opts = transaction_opts[:transaction]

    #TODO this thing should come through transaction_opts
    listing = Listing.find(opts[:listing_id])

    transaction_currency = Maybe(listing).price.currency.or_else(nil)

    minimum_commission = Maybe(transaction_currency).map { |currency|
      get_minimum_commission(opts[:payment_gateway], currency)
    }.or_else(nil)

    transaction = TransactionModel.new(
      community_id: opts[:community_id],
      listing_id: opts[:listing_id],
      starter_id: opts[:starter_id],
      listing_quantity: Maybe(opts)[:listing_quantity].or_else(1),
      payment_gateway: opts[:payment_gateway],
      payment_process: opts[:payment_process],
      commission_from_seller: Maybe(opts[:commission_from_seller]).or_else(0),
      minimum_commission: minimum_commission)

    conversation = transaction.build_conversation(
      community_id: opts[:community_id],
      listing_id: opts[:listing_id])

    conversation.participations.build(
      person_id: opts[:listing_author_id],
      is_starter: false,
      is_read: false)

    conversation.participations.build(
      person_id: opts[:starter_id],
      is_starter: true,
      is_read: true)

    #TODO: check this one out, how to handle pts[:content]?, it's missing from documentation
    if opts[:content].present?
      conversation.messages.build({
          content: opts[:content],
          sender_id: opts[:starter_id]})
    end

    if opts[:booking_fields].present?
      start_on = opts[:booking_fields][:start_on]
      end_on = opts[:booking_fields][:end_on]
      duration = DateUtils.duration_days(start_on, end_on)

      # Make sure listing_quantity equals duration
      if duration != transaction.listing_quantity
        return Result::Error.new("Listing quantity (#{transaction.listing_quantity}) must be equal to booking duration in days (#{duration})")
      end

      transaction.build_booking({
          start_on: start_on,
          end_on: end_on})
    end

    gateway_fields_response =
      case [opts[:payment_gateway], opts[:payment_process]]
      when [:braintree, :preauthorize]
        payment_gateway_id = BraintreePaymentGateway.where(community_id: opts[:community_id]).pluck(:id).first
        transaction.payment = BraintreePayment.new({
          community_id: opts[:community_id],
          payment_gateway_id: payment_gateway_id,
          status: "pending",
          payer_id: opts[:starter_id],
          recipient_id: opts[:listing_author_id],
          currency: "USD",
          sum: listing.price * transaction.listing_quantity
        })

        result = BraintreeSaleService.new(transaction.payment, opts[:gateway_fields]).pay(false)

        unless result.success?
          return Result::Error.new(result.message)
        end

        transaction.save!

        {}
      when [:paypal, :preauthorize]
        transaction.save!

        # Note: Quantity may be confusing in Paypal Checkout page, thus, we don't use separated unit price and quantity,
        # only the total price.
        quantity = 1
        total = listing.price * transaction.listing_quantity

        result = PaypalService::API::Api.payments.request(
        opts[:community_id],
        PaypalService::API::DataTypes.create_create_payment_request({
            transaction_id: transaction.id,
            item_name: listing.title,
            item_quantity: quantity,
            item_price: total,
            merchant_id: opts[:listing_author_id],
            order_total: total,
            success: transaction_opts[:gateway_fields][:success_url],
            cancel: transaction_opts[:gateway_fields][:cancel_url],
            merchant_brand_logo_url: transaction_opts[:gateway_fields][:merchant_brand_logo_url]
          })
        )

        unless result[:success]
          return Result::Error.new(result[:error_msg])
        end

        {redirect_url: result[:data][:redirect_url]}
      else
        # TODO Implement
        transaction.save!
        {}
      end

    #TODO: Fix to more sustainable solution (use model_to_entity, and add paypal and braintree relevant fields)
    #transition info is now added in controllers
    Result::Success.new(
      DataTypes.create_transaction_response(opts.merge({
            id: transaction.id,
            conversation_id: conversation.id,
            created_at: transaction.created_at,
            updated_at: transaction.updated_at
          }),
        gateway_fields_response
        )
      )
  end

  def reject(community_id, transaction_id)
    payment_type = TransactionModel.where(id: transaction_id, community_id: community_id).pluck(:payment_gateway).first

    case(payment_type)
    when "braintree"
      BraintreeService::Payments::Command.void_transaction(transaction_id, community_id)
      #TODO: Event handling also to braintree service?
      MarketplaceService::Transaction::Command.transition_to(transaction_id, "rejected")
    when "paypal"
      paypal_payment_api.void(community_id, transaction_id, {note: "Automatic void: Not responded to a request after 3 days"})
    end

    transaction = query(transaction_id)

    Result::Success.new(DataTypes.create_transaction_response(transaction))
  end


  def complete_preauthorization(transaction_id)
    transaction = MarketplaceService::Transaction::Query.transaction(transaction_id)
    payment_type = MarketplaceService::Community::Query.payment_type(transaction[:community_id])

    case payment_type
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
    raise "Not implemented"
  end

  def pay_invoice
    raise "Not implemented"
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
        commission_total: checkout_details[:commission_total]})
  end

  def charge_commission(transaction_id)
    transaction = query(transaction_id)
    commission_total = transaction[:commission_total]
    charge_request =
      {
        transaction_id: transaction_id,
        commission_total: commission_total,
        payment_name: I18n.t("paypal.transaction.commission_payment_name", transaction[:listing_title]),
        payment_desc: I18n.t("paypal.transaction.commission_payment_description", transaction[:listing_title]),
        minimum_commission: transaction[:minimum_commission]
      }

    paypal_billing_agreement_api().charge_commission(transaction[:community_id], transaction[:listing_author_id], charge_request)
  end

  def checkout_details(model)

    case model.payment_gateway.to_sym
    when :paypal
      payment = paypal_payment_api().get_payment(model.community.id, model.id)
      total =
        if payment[:data][:payment_total].present?
          payment[:data][:payment_total]
        elsif payment[:data][:authorization_total].present?
          payment[:data][:authorization_total]
        else
          model.listing_price * 1 #TODO fixme for booking (model.listing_quantity)
        end
      { total_price: total, commission_total: calculate_commission(total, model.commission_from_seller, model.minimum_commission) }
    else
      total = model.listing.price * 1 #TODO fixme for booking (model.listing_quantity)
      { total_price: total, commission_total: calculate_commission(total, model.commission_from_seller, model.minimum_commission) }
    end
  end

  def calculate_commission(total_price, commission_from_seller, minimum_commission)
    if commission_from_seller.blank? || commission_from_seller == 0
      Money.new(0, minimum_commission.currency)
    else
      commission_by_percentage = total_price * (commission_from_seller / 100.0)
      (commission_by_percentage > minimum_commission) ? commission_by_percentage : minimum_commission
    end
  end

  def get_minimum_commission(payment_gateway, currency)
    case payment_gateway
    when :paypal
      Maybe(paypal_minimum_commissions_api.get(currency)).or_else {
        raise "Couldn't find PayPal minimum commissions for currency #{currency}"
      }
    else
      Money.new(0, currency)
    end
  end

  def paypal_payment_api
    PaypalService::API::Api.payments
  end

  def paypal_billing_agreement_api
    PaypalService::API::Api.billing_agreements
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions
  end
end
