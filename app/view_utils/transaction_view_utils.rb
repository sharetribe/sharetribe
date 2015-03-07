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

  module_function

  def merge_messages_and_transitions(messages, transitions)
    messages = messages.map { |msg| MessageBubble[msg] }
    transitions = transitions.map { |tnx| MessageBubble[tnx] }

    (messages + transitions).sort_by { |hash| hash[:created_at] }
  end

  def create_messages_from_actions(transitions, author, starter, payment_sum)
    return [] if transitions.blank?

    ignored_transitions = ["free", "pending", "initiated", "pending_ext", "errored"] # Transitions that should not generate auto-message

    previous_states = [nil] + transitions.map { |transition| transition[:to_state] }

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
      t("conversations.message.paid", sum: humanized_money_with_symbol(payment_sum))
    when "accepted"
      t("conversations.message.accepted_request")
    when "rejected"
      t("conversations.message.rejected_request")
    when preauthorize_accepted
      t("conversations.message.accepted_request")
    when post_pay_accepted
      t("conversations.message.paid", sum: humanized_money_with_symbol(payment_sum))
    when "canceled"
      t("conversations.message.canceled_request")
    when "confirmed"
      t("conversations.message.confirmed_request")
    else
      raise("Unknown transition to state: #{state}")
    end
  end
end
