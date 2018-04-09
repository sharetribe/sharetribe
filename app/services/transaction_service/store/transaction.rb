module TransactionService::Store::Transaction

  TransactionModel = ::Transaction

  # While initiated is technically not a finished state it also
  # doesn't have any payment data to track against, so removing person
  # is still safe.
  FINISHED_TX_STATES = "'initiated', 'free', 'rejected', 'confirmed', 'canceled', 'errored'"

  module_function

  def create(tx_data)
    tx_model = TransactionModel.new(tx_data.except(:content, :booking_fields, :starting_page))

    build_conversation(tx_model, tx_data)
    build_booking(tx_model, tx_data)
    tx_model.save!
    tx_model
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
    TransactionModel.where(id: transaction_id, deleted: false).first
  end

  def get_in_community(community_id:, transaction_id:)
    TransactionModel.where(id: transaction_id, community_id: community_id, deleted: false).first
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
    tx_model = TransactionModel.where(id: transaction_id, community_id: community_id).first
    if tx_model
      address = tx_model.shipping_address || tx_model.build_shipping_address
      if addr.is_a?(ActionController::Parameters)
        addr = addr.permit(:name, :street1, :street2, :postal_code, :city, :country_code, :state_or_province)
      end
      address.update_attributes!(addr)
    end
  end

  def delete(community_id:, transaction_id:)
    tx_model = TransactionModel.where(id: transaction_id, community_id: community_id).first
    if tx_model
      tx_model.update_attribute(:deleted, true)
      tx_model
    end
  end

  def update_booking_uuid(community_id:, transaction_id:, booking_uuid:)
    unless booking_uuid.is_a?(UUIDTools::UUID)
      raise ArgumentError.new("booking_uuid must be a UUID, was: #{booking_uuid} (#{booking_uuid.class.name})")
    end

    tx_model = TransactionModel.where(community_id: community_id, id: transaction_id).first
    if tx_model
      tx_model.update_attributes(booking_uuid: UUIDUtils.raw(booking_uuid))
      tx_model
    end
  end

  def build_conversation(tx_model, tx_data)
    conversation = tx_model.build_conversation(
      tx_data.slice(:community_id, :listing_id, :starting_page))

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
      if tx_data[:booking_fields][:per_hour]
        start_time, end_time, per_hour = tx_data[:booking_fields].values_at(:start_time, :end_time, :per_hour)
        tx_model.build_booking(
          start_time: start_time,
          end_time: end_time,
          per_hour: per_hour)
      else
        start_on, end_on = tx_data[:booking_fields].values_at(:start_on, :end_on)

        tx_model.build_booking(
          start_on: start_on,
          end_on: end_on)
      end
    end
  end

  def is_booking?(tx_data)
    tx_data[:booking_fields] && ((tx_data[:booking_fields][:start_on] && tx_data[:booking_fields][:end_on]) ||
                                 (tx_data[:booking_fields][:start_time] && tx_data[:booking_fields][:end_time]))
  end

  def do_mark_as_unseen_by_other(tx_model, person_id)
    tx_model
      .conversation
      .participations
      .where("person_id != '#{person_id}'")
      .update_all(is_read: false)
  end

end
