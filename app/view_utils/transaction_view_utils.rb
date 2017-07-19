module TransactionViewUtils
  extend MoneyRails::ActionViewExtension
  extend ActionView::Helpers::TranslationHelper
  extend ActionView::Helpers::TagHelper

  MessageBubble = EntityUtils.define_builder(
    [:content, :string, :mandatory],
    [:sender, :hash, :mandatory],
    [:created_at, :time, :mandatory],
    [:mood, one_of: [:positive, :negative, :neutral]]
  )

  PriceBreakDownLocals = EntityUtils.define_builder(
    [:listing_price, :money, :mandatory],
    [:localized_unit_type, :string],
    [:localized_selector_label, :string],
    [:booking, :to_bool, default: false],
    [:start_on, :date],
    [:end_on, :date],
    [:duration, :fixnum],
    [:quantity, :fixnum],
    [:subtotal, :money],
    [:total, :money],
    [:shipping_price, :money],
    [:total_label, :string],
    [:unit_type, :symbol],
    [:stripe_fee, :money]
  )


  module_function

  def merge_messages_and_transitions(messages, transitions)
    messages = messages.map { |msg| MessageBubble[msg] }
    transitions = transitions.map { |tnx| MessageBubble[tnx] }

    (messages + transitions).sort_by { |hash| hash[:created_at] }
  end

  def create_messages_from_actions(transitions, author, starter, payment_sum)
    return [] if transitions.blank?

    ignored_transitions = [
      "free",
      "pending", # Deprecated
      "initiated",
      "pending_ext",
      "errored"
    ] # Transitions that should not generate auto-message

    previous_states = [nil] + transitions.map { |transition| transition[:to_state] }

    if transitions.map { |t| t[:to_state] }.include?("pending")
      ActiveSupport::Deprecation.warn("Transaction state 'pending' is deprecated and will be removed in the future.")
    end

    transitions
      .zip(previous_states)
      .reject { |(transition, previous_state)|
        ignored_transitions.include? transition[:to_state]
      }
      .map { |(transition, previous_state)|
        create_message_from_action(transition, previous_state, author, starter, payment_sum)
      }
  end

  def conversation_messages(message_entities, name_display_type)
    message_entities.map { |message_entity|
      sender = message_entity[:sender].merge(
        display_name: PersonViewUtils.person_entity_display_name(message_entity[:sender], name_display_type))
      message_entity.merge(mood: :neutral, sender: sender)
    }
  end

  def transition_messages(transaction, conversation, name_display_type)
    if transaction.present?
      author = conversation[:other_person].merge(
        display_name: PersonViewUtils.person_entity_display_name(conversation[:other_person], name_display_type))
      starter = conversation[:starter_person].merge(
        display_name: PersonViewUtils.person_entity_display_name(conversation[:starter_person], name_display_type))

      transitions = transaction[:transitions]
      payment_sum = transaction[:payment_total]

      create_messages_from_actions(transitions, author, starter, payment_sum)
    else
      []
    end
  end

  def create_message_from_action(transition, old_state, author, starter, payment_sum)
    preauthorize_accepted = ->(new_state) { new_state == "paid" && old_state == "preauthorized" }
    post_pay_accepted = ->(new_state) {
      # The condition here is simply "if new_state is paid", since due to migrations from old system there might be
      # transitions in "paid" state without previous state.
      new_state == "paid"
    }

    message = case transition[:to_state]
    when "preauthorized"
      {
        sender: starter,
        mood: :positive
      }
    when "accepted"
      ActiveSupport::Deprecation.warn("Transaction state 'accepted' is deprecated and will be removed in the future.")
      {
        sender: author,
        mood: :positive
      }
    when "rejected"
      {
        sender: author,
        mood: :negative
      }
    when preauthorize_accepted
      {
        sender: author,
        mood: :positive
      }
    when post_pay_accepted
      ActiveSupport::Deprecation.warn("Transaction state 'paid' without previous state is deprecated and will be removed in the future.")
      {
        sender: starter,
        mood: :positive
      }
    when "canceled"
      {
        sender: starter,
        mood: :negative
      }
    when "confirmed"
      {
        sender: starter,
        mood: :positive
      }
    else
      raise("Unknown transition to state: #{transition[:to_state]}")
    end

    MessageBubble[message.merge(
      created_at: transition[:created_at],
      content: create_content_from_action(transition[:to_state], old_state, payment_sum)
    )]
  end

  def create_content_from_action(state, old_state, payment_sum)
    preauthorize_accepted = ->(new_state) { new_state == "paid" && old_state == "preauthorized" }
    post_pay_accepted = ->(new_state) {
      # The condition here is simply "if new_state is paid", since due to migrations from old system there might be
      # transitions in "paid" state without previous state.
      new_state == "paid"
    }

    message = case state
    when "preauthorized"
      t("conversations.message.payment_preauthorized", sum: MoneyViewUtils.to_humanized(payment_sum))
    when "accepted"
      ActiveSupport::Deprecation.warn("Transaction state 'accepted' is deprecated and will be removed in the future.")
      t("conversations.message.accepted_request")
    when "rejected"
      t("conversations.message.rejected_request")
    when preauthorize_accepted
      t("conversations.message.received_payment", sum: MoneyViewUtils.to_humanized(payment_sum))
    when post_pay_accepted
      ActiveSupport::Deprecation.warn("Transaction state 'paid' without previous state is deprecated and will be removed in the future.")
      t("conversations.message.paid", sum: MoneyViewUtils.to_humanized(payment_sum))
    when "canceled"
      t("conversations.message.canceled_request")
    when "confirmed"
      t("conversations.message.confirmed_request")
    else
      raise("Unknown transition to state: #{state}")
    end
  end

  def price_break_down_locals(opts)
    PriceBreakDownLocals.call(opts)
  end

  def parse_booking_date(str)
    Date.parse(str) unless str.blank?
  end

  def stringify_booking_date(date)
    date.iso8601
  end

  def parse_quantity(quantity)
    Maybe(quantity)
      .select { |q| StringUtils.is_numeric?(q) }
      .map(&:to_i)
      .select { |q| q > 0 }
      .or_else(1)
  end


end
