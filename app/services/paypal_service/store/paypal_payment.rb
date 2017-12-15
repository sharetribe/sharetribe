module PaypalService::Store::PaypalPayment

  PaypalPaymentModel = ::PaypalPayment

  InitialPaymentData = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:merchant_id, :mandatory, :string],
    [:payment_status, const_value: :pending],
    [:pending_reason, :string],
    [:order_id, :string],
    [:order_date, :time],
    [:authorization_id, :string],
    [:authorization_date, :time],
    [:order_date, :time],
    [:currency, :mandatory, :string],
    [:order_total_cents, :fixnum],
    [:authorization_total_cents, :fixnum],
    [:commission_status, const_value: :not_charged])

  PaypalPayment = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:merchant_id, :mandatory, :string],
    [:payment_status, :mandatory, :symbol],
    [:pending_reason, :to_symbol],
    [:order_id, :string],
    [:order_date, :time],
    [:order_total, :money],
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
    :commission_payment_id,
    :commission_payment_date,
    :commission_total_cents,
    :commission_fee_total_cents,
    :commission_pending_reason
  ]

  module_function

  # Arguments:
  # Opts with mandatory key :data and optional keys :transaction_id, :community_id, :order_id, :authorization_id
  # Optional keys identify paypal payment row
  #
  # Return updated data or if no change, return nil
  def update(opts)
    if(opts[:data].nil?)
      raise ArgumentError.new("No data provided")
    end

    payment = find_payment(opts)
    old_data = from_model(payment)
    new_data = update_payment!(payment, opts[:data])

    new_data if data_changed?(old_data, new_data)
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

  def find_payment(opts)
    commission_payment_id = opts[:data].try(:[], :commission_payment_id)
    payment_id = opts[:data].try(:[], :payment_id)
    if opts[:community_id] && opts[:transaction_id]
      PaypalPaymentModel.where(community_id: opts[:community_id], transaction_id: opts[:transaction_id]).first
    elsif opts[:order_id]
      PaypalPaymentModel.where(order_id: opts[:order_id]).first
    elsif opts[:authorization_id]
      PaypalPaymentModel.where(authorization_id: opts[:authorization_id]).first
    elsif payment_id
      PaypalPaymentModel.where(payment_id: payment_id).first
    elsif commission_payment_id
      PaypalPaymentModel.where(commission_payment_id: commission_payment_id).first
    end
  end

  def data_changed?(old_data, new_data)
    old_data != new_data
  end

  def initial(order)
    order_total = order[:order_total]
    authorization_total = order[:authorization_total]
    total =
      if authorization_total
        { authorization_total_cents: authorization_total.cents, currency: authorization_total.currency.iso_code }
      else
        { order_total_cents: order_total.cents, currency: order_total.currency.iso_code }
      end

    InitialPaymentData.call(order.merge(total))
  end

  def create_payment_update(payment, update, current_state)
    cent_totals = [:order_total, :authorization_total, :fee_total, :payment_total, :commission_total, :commission_fee_total]
      .reduce({}) do |cent_totals, m_key|
      m = update[m_key]
      cent_totals["#{m_key}_cents".to_sym] = m.cents unless m.nil?
      cent_totals
    end

    adjustment_total = update[:adjustment_total]
    if adjustment_total && payment.payment_total.currency == adjustment_total.currency
      cent_totals[:payment_total_cents] = (payment.payment_total + adjustment_total).cents
    end

    payment_update = {}

    new_status = transform_status(update[:payment_status]) if update[:payment_status]

    new_pending_reason = transform_pending_reason(update[:pending_reason])
    new_state = to_state(new_status, new_pending_reason) if new_status

    commission_new_status = transform_status(update[:commission_status]) if update[:commission_status]
    commission_new_pending_reason = transform_pending_reason(update[:commission_pending_reason])

    if(new_state && valid_transition?(current_state, new_state))
      payment_update[:payment_status] = new_status
      payment_update[:pending_reason] = new_pending_reason
    end

    if (commission_new_status)
      payment_update[:commission_status] = commission_new_status
      payment_update[:commission_pending_reason] = commission_new_pending_reason
    end

    payment_update = HashUtils.sub(update, *OPT_UPDATE_FIELDS).merge(cent_totals).merge(payment_update)

    return payment_update
  end

  def transform_status(status)
    status.is_a?(Symbol) ? status : status.downcase.to_sym
  end

  def transform_pending_reason(reason)
    if(reason.nil?)
      :none
    elsif(reason.is_a? Symbol)
      reason
    elsif(reason == "payment-review") # Canonical version of payment-review status is with dash
      reason.downcase.to_sym
    else
      reason.downcase.gsub(/[-_]/, "").to_sym # Normalize dashes and underscores away
    end
  end

  def update_payment!(payment, data)
    current_state = to_state(payment.payment_status.to_sym, payment.pending_reason.to_sym)
    payment_update = create_payment_update(payment, data, current_state)

    if payment.nil?
      raise ArgumentError.new("No matching payment to update.")
    end

    payment.update_attributes!(payment_update)

    from_model(payment.reload)
  end

  STATES = {
    order: [:pending, :order],
    payment_review: [:pending, :"payment-review"],
    authorized: [:pending, :authorization],
    expired: [:expired, :none],
    pending_ext: [:pending, :ext],
    completed: [:completed, :none],
    voided: [:voided, :none],
    denied: [:denied, :none]
  }

  INTERNAL_REASONS = [:none, :authorization, :order, :"payment-review"]

  STATE_HIERARCHY = {
    order: 0,
    payment_review: 1,
    authorized: 2,
    expired: 3,
    voided: 3,
    pending_ext: 3,
    completed: 4,
    denied: 4,
  }

  def valid_transition?(current_state, new_state)
    STATE_HIERARCHY[current_state] < STATE_HIERARCHY[new_state]
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
