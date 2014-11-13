module PaypalService::Store::PaypalPayment

  PaypalPaymentModel = ::PaypalPayment

  InitialPaymentData = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:payment_status, const_value: :pending],
    [:pending_reason, :string],
    [:order_id, :mandatory, :string],
    [:order_date, :mandatory, :time],
    [:currency, :mandatory, :string],
    [:order_total_cents, :mandatory, :fixnum],
    [:commission_status, const_value: :not_charged])

  PaypalPayment = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:payment_status, :mandatory, :symbol],
    [:pending_reason, :to_symbol],
    [:order_id, :mandatory, :string],
    [:order_date, :mandatory, :time],
    [:order_total, :mandatory, :money],
    [:authorization_id, :string],
    [:authorization_date, :time],
    [:authorization_expires_date, :time],
    [:authorization_total, :money],
    [:payment_id, :string],
    [:payment_date, :time],
    [:payment_total, :money],
    [:fee_total, :money],
    [:commission_payment_id, :string],
    [:commission_payment_date, :time],
    [:commission_total, :money],
    [:commission_fee_total, :money],
    [:commission_status, :mandatory, :symbol],
    [:commission_pending_reason, :string])

  OPT_UPDATE_FIELDS = [
    :order_id,
    :order_date,
    :order_total_cents,
    :authorization_id,
    :authorization_date,
    :authorization_expires_date,
    :authorization_total_cents,
    :payment_id,
    :payment_date,
    :payment_total_cents,
    :fee_total_cents,
    :pending_reason,
    :commission_payment_id,
    :commission_payment_date,
    :commission_total_cents,
    :commission_fee_total_cents,
    :commission_pending_reason
  ]

  module_function

  def update(community_id, transaction_id, order)
    payment = PaypalPaymentModel.where(
      community_id: community_id,
      transaction_id: transaction_id
      ).first
    update_payment(payment, order)
  end

  def ipn_update(ipn_entity)
    payment = PaypalPaymentModel.where(
      "authorization_id = ? or order_id = ?", ipn_entity[:authorization_id], ipn_entity[:order_id]).first

    old_data = from_model(payment)
    new_data = update_payment(payment, ipn_entity)
    new_data if old_data != new_data
  end

  def create(community_id, transaction_id, order)
    begin
      model = PaypalPaymentModel.create!(
        initial(
          order
            .merge({community_id: community_id, transaction_id: transaction_id})
          ))
      from_model(model)
    rescue ActiveRecord::RecordNotUnique => rnu
      get(community_id, transaction_id)
    end
  end

  def get(community_id, transaction_id)
    Maybe(PaypalPaymentModel.where(
        community_id: community_id,
        transaction_id: transaction_id
        ).first)
      .map { |model| from_model(model) }
      .or_else(nil)
  end

  ## Privates
  def from_model(paypal_payment)
    hash = HashUtils.compact(
      EntityUtils.model_to_hash(paypal_payment).merge({
          order_total: paypal_payment.order_total,
          authorization_total: paypal_payment.authorization_total,
          fee_total: paypal_payment.fee_total,
          payment_total: paypal_payment.payment_total,
          payment_status: paypal_payment[:payment_status].to_sym,
          commission_total: paypal_payment.commission_total,
          commission_fee_total: paypal_payment.commission_fee_total,
          commission_status: paypal_payment[:commission_status].to_sym
        }))

    PaypalPayment.call(hash)
  end

  def initial(order)
    order_total = order[:order_total]
    InitialPaymentData.call(
      order.merge({order_total_cents: order_total.cents, currency: order_total.currency.iso_code}))
  end

  def find_payment(payment_entity)
    payment = if (payment_entity[:order_id])
                PaypalPaymentModel.where(order_id: payment_entity[:order_id]).first
              else
                PaypalPaymentModel.where(authorization_id: payment_entity[:authorization_id]).first
              end

    if (payment && payment_entity[:receiver_id] == payment.receiver_id && payment_entity[:payer_id] == payment.payer_id)
      return payment
    end

    return nil
  end

  def create_payment_update(order)
    cent_totals = [:order_total, :authorization_total, :fee_total, :payment_total, :commission_total, :commission_fee_total]
      .reduce({}) do |cent_totals, m_key|
      m = order[m_key]
      cent_totals["#{m_key}_cents".to_sym] = m.cents unless m.nil?
      cent_totals
    end

    payment_update = {}
    payment_update[:payment_status] =
      if (order[:payment_status].is_a? Symbol)
        order[:payment_status]
      else
        order[:payment_status].downcase.to_sym
      end

    payment_update[:pending_reason] =
      if (order[:pending_reason].nil?)
        :none
      elsif (order[:pending_reason].is_a? Symbol)
        order[:pending_reason]
      else
        order[:pending_reason].downcase.gsub(/[-_]/, "").to_sym
      end

    payment_update[:commission_status] = order[:commission_status].downcase.to_sym if order[:commission_status]
    payment_update = HashUtils.sub(order, *OPT_UPDATE_FIELDS).merge(cent_totals).merge(payment_update)

    return payment_update
  end

  def update_payment(payment, data)
    payment_update = create_payment_update(data)

    if payment.nil?
      raise ArgumentError.new("No matching payment to update.")
    end

    #update status and reason only on valid transition
    unless(valid_transition?(payment, payment_update))
      payment_update.delete(:payment_status)
      payment_update.delete(:pending_reason)
    end

    payment.update_attributes!(payment_update)

    from_model(payment.reload)
  end

  STATES = {
    order: [:pending, :order],
    authorized: [:pending, :authorization],
    pending_ext: [:pending, :ext],
    completed: [:completed, :none],
    voided: [:voided, :none],
    denied: [:denied, :none]
  }

  INTERNAL_REASONS = [:none, :authorization, :order]

  STATE_HIERARCHY = {
    order: 0,
    authorized: 1,
    voided: 2,
    pending_ext: 2,
    completed: 3,
    denied: 4,
  }

  def valid_transition?(payment, payment_update)
    current_state = to_state(payment.payment_status.to_sym, payment.pending_reason.to_sym)
    transition_state = to_state(payment_update[:payment_status], payment_update[:pending_reason])

    STATE_HIERARCHY[current_state] < STATE_HIERARCHY[transition_state]
  end

  def to_state(status, reason)
    state = STATES.find { |_, arr| arr == [status, pending_ext_or_internal(reason)] }

    unless state.nil?
      state.first
    else
      raise ArgumentError.new("No matching state for status: #{status} and reason: #{reason}.")
    end
  end

  def pending_ext_or_internal(reason)
    INTERNAL_REASONS.include?(reason) ? reason : :ext
  end

  ### DEPRECATED! ###
  def for_transaction(transaction_id)
    Maybe(PaypalPaymentModel.where(transaction_id: transaction_id).first)
      .map { |model| from_model(model) }
      .or_else(nil)
  end
end
