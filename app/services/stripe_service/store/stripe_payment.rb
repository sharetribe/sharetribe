module StripeService::Store::StripePayment

  StripePaymentModel = ::StripePayment

  InitialPaymentData = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:status, const_value: :pending],
    [:currency, :mandatory, :string],
    [:sum_cents, :fixnum],
    [:commission_cents, :fixnum],
    [:fee_cents, :fixnum],
    [:subtotal_cents, :fixnum],
    [:stripe_charge_id, :string]
  )

  StripePayment = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:status, :mandatory, :to_symbol],
    [:sum, :money],
    [:commission, :money],
    [:fee, :money],
    [:real_fee, :money],
    [:subtotal, :money],
    [:stripe_charge_id, :string],
    [:stripe_transfer_id, :string],
    [:transfered_at, :time],
    [:available_on, :time]
  )

  module_function

  def update(opts)
    if(opts[:data].nil?)
      raise ArgumentError.new("No data provided")
    end

    payment = find_payment(opts)
    old_data = from_model(payment)
    update_payment!(payment, opts[:data])
  end

  def create(community_id, transaction_id, order)
    payment_data = InitialPaymentData.call(order.merge({community_id: community_id, transaction_id: transaction_id}))
    model = StripePaymentModel.create!(payment_data)
    from_model(model)
  end

  def get(community_id, transaction_id)
    Maybe(StripePaymentModel.where(
        community_id: community_id,
        transaction_id: transaction_id
        ).first)
      .map { |model| from_model(model) }
      .or_else(nil)
  end

  def from_model(stripe_payment)
    hash = HashUtils.compact(
      EntityUtils.model_to_hash(stripe_payment).merge({
          sum: stripe_payment.sum,
          fee: stripe_payment.fee,
          commission: stripe_payment.commission,
          subtotal: stripe_payment.subtotal,
          real_fee: stripe_payment.real_fee,
        }))
    StripePayment.call(hash)
  end

  def find_payment(opts)
    StripePaymentModel.where(
      "(community_id = ? and transaction_id = ?)",
      opts[:community_id],
      opts[:transaction_id]
    ).first
  end

  def data_changed?(old_data, new_data)
    old_data != new_data
  end

  def update_payment!(payment, data)
    payment.update_attributes!(data)
    from_model(payment.reload)
  end
end
