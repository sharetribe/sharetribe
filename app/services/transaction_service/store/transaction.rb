module TransactionService::Store::Transaction

  TransactionModel = ::Transaction
  ShippingAddressModel = ::ShippingAddress

  NewTransaction = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:community_uuid, :string, :mandatory, transform_with: UUIDUtils::RAW], # :string type for raw bytes
    [:listing_id, :fixnum, :mandatory],
    [:listing_uuid, :string, :mandatory, transform_with: UUIDUtils::RAW], # :string type for raw bytes
    [:starter_id, :string, :mandatory],
    [:starter_uuid, :string, :mandatory, transform_with: UUIDUtils::RAW], # :string type for raw bytes
    [:listing_quantity, :fixnum, default: 1],
    [:listing_title, :string, :mandatory],
    [:listing_author_id, :string, :mandatory],
    [:listing_author_uuid, :string, :mandatory, transform_with: UUIDUtils::RAW], # :string type for raw bytes
    [:unit_type, :to_symbol, one_of: [:hour, :day, :night, :week, :month, :custom, nil]],
    [:unit_price, :money, default: Money.new(0)],
    [:unit_tr_key, :string],
    [:unit_selector_tr_key, :string],
    [:availability, :to_symbol, one_of: [:none, :booking]],
    [:shipping_price, :money],
    [:delivery_method, :to_symbol, one_of: [:none, :shipping, :pickup], default: :none],
    [:payment_process, one_of: [:none, :postpay, :preauthorize]],
    [:payment_gateway, one_of: [:paypal, :checkout, :braintree, :stripe, :none]],
    [:commission_from_seller, :fixnum, :mandatory],
    [:automatic_confirmation_after_days, :fixnum, :mandatory],
    [:minimum_commission, :money, :mandatory],
    [:content, :string],
    [:booking_uuid, :string, transform_with: UUIDUtils::RAW], # :string type for raw bytes
    [:booking_fields, :hash])

  Transaction = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:community_id, :fixnum, :mandatory],
    [:community_uuid, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
    [:listing_id, :fixnum, :mandatory],
    [:listing_uuid, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
    [:starter_id, :string, :mandatory],
    [:starter_uuid, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
    [:listing_quantity, :fixnum, :mandatory],
    [:listing_title, :string, :mandatory],
    [:listing_author_id, :string, :mandatory],
    [:listing_author_uuid, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
    [:unit_type, :to_symbol, one_of: [:hour, :day, :night, :week, :month, :custom, nil]],
    [:unit_price, :money, default: Money.new(0)],
    [:unit_tr_key, :string],
    [:unit_selector_tr_key, :string],
    [:availability, :to_symbol, one_of: [:none, :booking]],
    [:shipping_price, :money],
    [:delivery_method, :to_symbol, :mandatory, one_of: [:none, :shipping, :pickup]],
    [:payment_process, :to_symbol, one_of: [:none, :postpay, :preauthorize]],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :checkout, :braintree, :stripe, :none]],
    [:commission_from_seller, :fixnum],
    [:automatic_confirmation_after_days, :fixnum, :mandatory],
    [:minimum_commission, :money],
    [:last_transition_at, :time],
    [:current_state, :to_symbol],
    [:shipping_address, :hash],
    [:booking_uuid, :uuid, transform_with: UUIDUtils::PARSE_RAW],
    [:booking, :hash])

  ShippingAddress = EntityUtils.define_builder(
    [:status, :string],
    [:name, :string],
    [:phone, :string],
    [:street1, :string],
    [:street2, :string],
    [:postal_code, :string],
    [:city, :string],
    [:state_or_province, :string],
    [:country, :string],
    [:country_code, :string])

  Booking = EntityUtils.define_builder(
    [:start_on, :date, :mandatory],
    [:end_on, :date, :mandatory],
    [:duration, :fixnum, :mandatory])


  # While initiated is technically not a finished state it also
  # doesn't have any payment data to track against, so removing person
  # is still safe.
  FINISHED_TX_STATES = "'initiated', 'free', 'rejected', 'confirmed', 'canceled', 'errored'"

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

  # Mark transaction as unseen, i.e. something new (e.g. transition) has happened
  #
  # Under the hood, this is stored to conversation, which is not optimal since that ties transaction and
  # conversation tightly together.
  def mark_as_unseen_by_other(community_id:, transaction_id:, person_id:)
    tx_model = TransactionModel.where(community_id: community_id, id: transaction_id).first
    do_mark_as_unseen_by_other(tx_model, person_id) if tx_model

    nil
  end

  def get(transaction_id)
    Maybe(TransactionModel.where(id: transaction_id, deleted: false).first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def get_in_community(community_id:, transaction_id:)
    Maybe(TransactionModel.where(id: transaction_id, community_id: community_id, deleted: false).first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def unfinished_tx_count(person_id)
    # We include deleted transactions on purpose. They might be in a
    # state where e.g. IPN message causes them to proceed so removing
    # user data would be unwise.
    TransactionModel
      .where("starter_id = ? OR listing_author_id = ?", person_id, person_id)
      .where("current_state NOT IN (#{FINISHED_TX_STATES})")
      .count
  end

  def upsert_shipping_address(community_id:, transaction_id:, addr:)
    Maybe(TransactionModel.where(id: transaction_id, community_id: community_id).first)
      .map { |m| ShippingAddressModel.where(transaction_id: m.id).first_or_create!(transaction_id: m.id) }
      .map { |a| a.update_attributes!(addr_fields(addr)) }
      .or_else { nil }
  end

  def delete(community_id:, transaction_id:)
    Maybe(TransactionModel.where(id: transaction_id, community_id: community_id).first)
      .each { |m| m.update_attribute(:deleted, true) }
      .map { |m| from_model(m.reload) }
      .or_else(nil)
  end

  def update_booking_uuid(community_id:, transaction_id:, booking_uuid:)
    unless booking_uuid.is_a?(UUIDTools::UUID)
      raise ArgumentError.new("booking_uuid must be a UUID, was: #{booking_uuid} (#{booking_uuid.class.name})")
    end

    Maybe(TransactionModel.where(community_id: community_id, id: transaction_id).first)
      .each { |tx_model| tx_model.update_attributes(booking_uuid: UUIDUtils.raw(booking_uuid)) }
      .map { |tx_model| from_model(tx_model.reload) }
      .or_else(nil)
  end

  ## Privates

  def from_model(model)
    Maybe(model)
      .map { |m|
        hash = EntityUtils.model_to_hash(m)
               .merge({unit_price: m.unit_price, minimum_commission: m.minimum_commission, shipping_price: m.shipping_price })

        hash = add_opt_shipping_address(hash, m)
        hash = add_opt_booking(hash, m)

        hash
      }
      .map { |hash| Transaction.call(hash) }
      .or_else(nil)
  end

  def add_opt_shipping_address(hash, m)
    if m.shipping_address
      hash.merge({shipping_address: ShippingAddress.call(EntityUtils.model_to_hash(m.shipping_address)) })
    else
      hash
    end
  end

  def add_opt_booking(hash, m)
    if m.booking
      booking_data = EntityUtils.model_to_hash(m.booking)
      hash.merge(booking: Booking.call(booking_data.merge(duration: m.listing_quantity)))
    else
      hash
    end
  end

  def addr_fields(addr)
    HashUtils.compact(ShippingAddress.call(addr))
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
      start_on, end_on = tx_data[:booking_fields].values_at(:start_on, :end_on)

      tx_model.build_booking(
        start_on: start_on,
        end_on: end_on)
    end
  end

  def is_booking?(tx_data)
    tx_data[:booking_fields] && tx_data[:booking_fields][:start_on] && tx_data[:booking_fields][:end_on]
  end

  def do_mark_as_unseen_by_other(tx_model, person_id)
    tx_model
      .conversation
      .participations
      .where("person_id != '#{person_id}'")
      .update_all(is_read: false)
  end

end
