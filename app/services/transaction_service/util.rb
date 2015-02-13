module TransactionService::Util

  TransactionModel = ::Transaction

  module_function

  def create_tx_model_with_conversation(opts)
    tx = TransactionModel.new(
      community_id: opts[:community_id],
      listing_id: opts[:listing_id],
      starter_id: opts[:starter_id],
      listing_quantity: Maybe(opts)[:listing_quantity].or_else(1),
      listing_title: opts[:listing_title],
      unit_price: Maybe(opts[:unit_price]).or_else(Money.new(0)),
      listing_author_id: opts[:listing_author_id],
      payment_gateway: opts[:payment_gateway],
      payment_process: opts[:payment_process],
      commission_from_seller: Maybe(opts[:commission_from_seller]).or_else(0),
      automatic_confirmation_after_days: opts[:automatic_confirmation_after_days],
      minimum_commission: Maybe(opts[:minimum_commission]).or_else(Money.new(0)))

    conversation = tx.build_conversation(
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

    if opts[:content].present?
      conversation.messages.build({
          content: opts[:content],
          sender_id: opts[:starter_id]})
    end

    if is_booking?(opts)
      # TODO Move quantity calculation to tx service to get rid of this silly check
      # Make sure listing_quantity equals duration
      if booking_duration(opts) != tx.listing_quantity
        raise ArgumentException.new("Listing quantity (#{tx.listing_quantity}) must be equal to booking duration in days (#{booking_duration(opts)})")
      end

      start_on = opts[:booking_fields][:start_on]
      end_on = opts[:booking_fields][:end_on]

      tx.build_booking({
          start_on: start_on,
          end_on: end_on})
    end

    tx.save!
    tx
  end


  def is_booking?(opts_tx)
    opts_tx[:booking_fields] && opts_tx[:booking_fields][:start_on] && opts_tx[:booking_fields][:end_on]
  end

  def booking_duration(opts_tx)
    start_on = opts_tx[:booking_fields][:start_on]
    end_on = opts_tx[:booking_fields][:end_on]
    duration = DateUtils.duration_days(start_on, end_on)
  end
end
