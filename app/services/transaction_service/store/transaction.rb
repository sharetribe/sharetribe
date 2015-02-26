module TransactionService::Store::Transaction

  TransactionModel = ::Transaction

  NewTransaction = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:listing_id, :fixnum, :mandatory],
    [:starter_id, :string, :mandatory],
    [:listing_quantity, :fixnum, default: 1],
    [:listing_title, :string, :mandatory],
    [:listing_author_id, :string, :mandatory],
    [:unit_price, :money, default: Money.new(0)],
    [:shipping_price, :money],
    [:delivery_method, :to_symbol, one_of: [:none, :shipping, :pickup], default: :none],
    [:payment_process, one_of: [:none, :postpay, :preauthorize]],
    [:payment_gateway, one_of: [:paypal, :checkout, :braintree, :none]],
    [:commission_from_seller, :fixnum, :mandatory],
    [:automatic_confirmation_after_days, :fixnum, :mandatory],
    [:minimum_commission, :money, :mandatory],
    [:content, :string],
    [:booking_fields, :hash])

  Transaction = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:community_id, :fixnum, :mandatory],
    [:listing_id, :fixnum, :mandatory],
    [:starter_id, :string, :mandatory],
    [:listing_quantity, :fixnum, :mandatory],
    [:listing_title, :string, :mandatory],
    [:listing_author_id, :string, :mandatory],
    [:unit_price, :money, :mandatory],
    [:shipping_price, :money],
    [:delivery_method, :to_symbol, :mandatory, one_of: [:none, :shipping, :pickup]],
    [:payment_process, :to_symbol, one_of: [:none, :postpay, :preauthorize]],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :checkout, :braintree, :none]],
    [:commission_from_seller, :fixnum, :mandatory],
    [:automatic_confirmation_after_days, :fixnum, :mandatory],
    [:minimum_commission, :money, :mandatory],
    [:last_transition_at, :time],
    [:current_state, :to_symbol])

  FINISHED_TX_STATES = "'free', 'rejected', 'confirmed', 'canceled', 'errored'"

  module_function

  def create(opts)
    tx_data = HashUtils.compact(NewTransaction.call(opts))
    tx_model = TransactionModel.new(tx_data.except(:content, :booking_fields))
    build_conversation(tx_model, tx_data)
    build_booking(tx_model, tx_data)

    tx_model.save!
    from_model(tx_model)
  end

  def add_message(community_id:, transaction_id:, sender_id:, message:)
    tx_model = TransactionModel.where(community_id: community_id, id: transaction_id).first
    if tx_model
      tx_model.conversation.messages.create({content: message, sender_id: sender_id})
      do_mark_as_unseen_by_other(tx_model, sender_id)
    end

    nil
  end

  # Mark transasction as unseen, i.e. something new (e.g. transition) has happened
  #
  # Under the hood, this is stored to conversation, which is not optimal since that ties transaction and
  # conversation tightly together.
  def mark_as_unseen_by_other(community_id:, transaction_id:, person_id:)
    tx_model = TransactionModel.where(community_id: community_id, id: transaction_id).first
    do_mark_as_unseen_by_other(tx_model, person_id) if tx_model

    nil
  end

  def get(transaction_id)
    Maybe(TransactionModel.where(id: transaction_id).first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def get_in_community(community_id:, transaction_id:)
    Maybe(TransactionModel.where(id: transaction_id, community_id: community_id).first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def unfinished_tx_count(person_id)
    TransactionModel
      .where("starter_id = ? OR listing_author_id = ?", person_id, person_id)
      .where("current_state NOT IN (#{FINISHED_TX_STATES})")
      .count
  end


  ## Privates

  def from_model(model)
    Maybe(model)
      .map { |m|
        EntityUtils.model_to_hash(m)
        .merge({unit_price: m.unit_price , minimum_commission: m.minimum_commission })
      }
      .map { |hash| Transaction.call(hash) }
      .or_else(nil)
  end

  def build_conversation(tx_model, tx_data)
    conversation = tx_model.build_conversation(
      tx_data.slice(:community_id, :listing_id))

    conversation.participations.build(
      person_id: tx_data[:listing_author_id],
      is_starter: false,
      is_read: false)

    conversation.participations.build(
      person_id: tx_data[:starter_id],
      is_starter: true,
      is_read: true)

    if tx_data[:content].present?
      conversation.messages.build({
          content: tx_data[:content],
          sender_id: tx_data[:starter_id]})
    end
  end

  def build_booking(tx_model, tx_data)
    if is_booking?(tx_data)

      # TODO What's the correct place for the booking calculation logic?
      # Make sure listing_quantity equals duration
      if booking_duration(tx_data) != tx_model.listing_quantity
        raise ArgumentException.new("Listing quantity (#{tx_listing_quantity}) must be equal to booking duration in days (#{booking_duration(tx_data)})")
      end

      start_on = tx_data[:booking_fields][:start_on]
      end_on = tx_data[:booking_fields][:end_on]
      tx_model.build_booking({start_on: start_on, end_on: end_on})
    end
  end

  def is_booking?(tx_data)
    tx_data[:booking_fields] && tx_data[:booking_fields][:start_on] && tx_data[:booking_fields][:end_on]
  end

  def booking_duration(tx_data)
    start_on = tx_data[:booking_fields][:start_on]
    end_on = tx_data[:booking_fields][:end_on]
    DateUtils.duration_days(start_on, end_on)
  end

  def do_mark_as_unseen_by_other(tx_model, person_id)
    tx_model
      .conversation
      .participations
      .where("person_id != '#{person_id}'")
      .update_all(is_read: false)
  end

end
