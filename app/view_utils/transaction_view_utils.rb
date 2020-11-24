module TransactionViewUtils
  extend MoneyRails::ActionViewExtension
  extend ActionView::Helpers::TranslationHelper
  extend ActionView::Helpers::TagHelper

  MessageBubble = EntityUtils.define_builder(
    [:content, :string, :mandatory],
    [:sender, :mandatory],
    [:created_at, :time, :mandatory],
    [:mood, one_of: [:positive, :negative, :neutral]],
    [:admin, :to_bool, :optional]
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
    [:sum, :money],
    [:fee, :money],
    [:seller_gets, :money],
    [:start_time, :time],
    [:end_time, :time],
    [:per_hour, :to_bool, default: false],
    [:buyer_fee, :money]
  )


  module_function

  def merge_messages_and_transitions(messages, transitions)
    messages = messages.map { |msg| MessageBubble[msg] }
    transitions = transitions.map { |tnx| MessageBubble[tnx] }

    (messages + transitions).sort_by { |hash| hash[:created_at] }
  end

  def create_messages_from_actions(transitions, author, starter, payment_sum, payment_gateway, show_sum=true)
    return [] if transitions.blank?

    ignored_transitions = [
      "free",
      "pending", # Deprecated
      "initiated",
      "payment_intent_requires_action",
      "payment_intent_failed",
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
        create_message_from_action(transition, previous_state, author, starter, payment_sum, payment_gateway, show_sum)
      }
  end

  def conversation_messages(messages, name_display_type)
    messages.map { |message|
      MessageBubble.call(
        content: message.content,
        sender: message.sender,
        created_at: message.created_at,
        mood: :neutral
      )
    }
  end

  def transition_messages(transaction, conversation, name_display_type)
    if transaction.present?
      transitions = transaction.transaction_transitions
      payment_sum = transaction.payment_total
      payment_gateway = transaction.payment_gateway
      show_sum = transaction.buyer_commission <= 0
      create_messages_from_actions(transitions, transaction.author, transaction.starter, payment_sum, payment_gateway, show_sum)
    else
      []
    end
  end

  def create_message_from_action(transition, old_state, author, starter, payment_sum, payment_gateway, show_sum)
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
        sender: transition_user(transition, starter),
        admin: transition[:metadata] && transition[:metadata]['executed_by_admin'],
        mood: :negative
      }
    when "disputed"
      {
        sender: transition_user(transition, starter),
        admin: transition[:metadata] && transition[:metadata]['executed_by_admin'],
        mood: :negative
      }
    when "confirmed"
      {
        sender: transition_user(transition, starter),
        admin: transition[:metadata] && transition[:metadata]['executed_by_admin'],
        mood: :positive
      }
    when "refunded"
      {
        sender: transition_user(transition, starter),
        admin: transition[:metadata] && transition[:metadata]['executed_by_admin'],
        mood: :positive
      }
    when "dismissed"
      {
        sender: transition_user(transition, starter),
        admin: transition[:metadata] && transition[:metadata]['executed_by_admin'],
        mood: :negative
      }
    else
      raise("Unknown transition to state: #{transition[:to_state]}")
    end

    MessageBubble[message.merge(
      created_at: transition[:created_at],
      content: create_content_from_action(transition[:to_state], old_state, payment_sum, payment_gateway, author, show_sum)
    )]
  end

  def create_content_from_action(state, old_state, payment_sum, payment_gateway, author, show_sum)
    preauthorize_accepted = ->(new_state) { new_state == "paid" && old_state == "preauthorized" }
    post_pay_accepted = ->(new_state) {
      # The condition here is simply "if new_state is paid", since due to migrations from old system there might be
      # transitions in "paid" state without previous state.
      new_state == "paid"
    }
    amount = MoneyViewUtils.to_humanized(payment_sum)

    message = case state
    when "preauthorized"
      if show_sum
        t("conversations.message.payment_preauthorized", sum: amount)
      else
        t("conversations.message.payment_preauthorized_wo_sum")
      end
    when "accepted"
      ActiveSupport::Deprecation.warn("Transaction state 'accepted' is deprecated and will be removed in the future.")
      t("conversations.message.accepted_request")
    when "rejected"
      t("conversations.message.rejected_request")
    when preauthorize_accepted
      if payment_gateway == :stripe
        if show_sum
          t("conversations.message.stripe.held_payment", sum: amount)
        else
          t("conversations.message.stripe.held_payment_wo_sum")
        end
      elsif show_sum
        t("conversations.message.received_payment", sum: amount)
      else
        t("conversations.message.received_payment_wo_sum")
      end
    when post_pay_accepted
      ActiveSupport::Deprecation.warn("Transaction state 'paid' without previous state is deprecated and will be removed in the future.")
      t("conversations.message.paid", sum: amount)
    when "canceled"
      t("conversations.message.canceled_request")
    when "disputed"
      t("conversations.message.canceled_the_order")
    when "confirmed"
      if payment_gateway == :stripe
        t("conversations.message.stripe.confirmed_request", author_name: author[:display_name])
      else
        t("conversations.message.confirmed_request")
      end
    when "refunded"
      t("conversations.message.marked_as_refunded")
    when "dismissed"
      "#{t('conversations.message.dismissed_the_cancellation')} #{payment_gateway == :stripe ? t('conversations.message.payment_has_now_been_transferred', seller: author[:display_name]) : ''}"
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

  def parse_booking_datetime(str)
    Time.zone.parse(str) unless str.blank?
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

  def transition_user(transition, starter)
    transition[:metadata] && transition[:metadata]['user_id'] && Person.find_by_id(transition[:metadata]['user_id']) || starter
  end

end
