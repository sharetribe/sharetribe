module TransactionService::Util

  TransactionModel = ::Transaction

  module_function

  def build_tx_model_with_conversation(opts)
    tx = TransactionModel.new(
      community_id: opts[:community_id],
      listing_id: opts[:listing_id],
      starter_id: opts[:starter_id],
      listing_quantity: Maybe(opts)[:listing_quantity].or_else(1),
      payment_gateway: opts[:payment_gateway],
      payment_process: opts[:payment_process],
      commission_from_seller: Maybe(opts[:commission_from_seller]).or_else(0),
      # automatic_confirmation_after_days: opts[:automatic_confirmation_after_days], # always nil?
      minimum_commission: opts[:minimum_commission])

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

    if opts[:booking_fields].present?
      start_on = opts[:booking_fields][:start_on]
      end_on = opts[:booking_fields][:end_on]

      tx.build_booking({
          start_on: start_on,
          end_on: end_on})
    end


    return [tx, conversation]
  end

end
