module TransactionViewUtils
  extend MoneyRails::ActionViewExtension
  extend ActionView::Helpers::TranslationHelper

  module_function

  def merge_messages_and_transitions(messages, transitions)
    messages_with_type = messages.map(&:to_h).map do |message|
      message[:type] = "message"
      message
    end

    transitions_with_type = transitions.map(&:to_h).map do |transition|
      transition[:type] = "transition"
      transition
    end

    (messages_with_type + transitions_with_type).sort_by { |hash| hash[:created_at] }
  end

  def create_messages_from_actions(transaction)
    transitions = transaction[:transitions]
    return [] if transitions.blank?

    previous_states = [nil] + transitions.map { |transition| transition[:to_state] }

    transitions.reject { |transition|
      ["free", "pending"].include? transition[:to_state]
    }. zip(previous_states).map { |(transition, previous_state)|
      create_message_from_action(transaction, transition, previous_state)
    }
  end

  def create_message_from_action(transaction, transition, old_state)
    direction = transaction[:direction]

    case transition[:to_state]
    when "preauthorized"
      {sender: transaction[:starter], content: t("conversations.message.paid", sum: humanized_money_with_symbol(transaction[:payment_sum])), created_at: transition[:created_at], mood: :positive }
    when "accepted"
      {sender: transaction[:author], content: t("conversations.message.accepted_#{direction}"), created_at: transition[:created_at], mood: :positive }
    when "rejected"
      {sender: transaction[:author], content: t("conversations.message.rejected_#{direction}"), created_at: transition[:created_at], mood: :negative }
    when "paid"
      if old_state == "preauthorized"
        {sender: transaction[:author], content: t("conversations.message.accepted_#{direction}"), created_at: transition[:created_at], mood: :positive }
      elsif old_state == "accepted"
        {sender: transaction[:starter], content: t("conversations.message.paid", sum: humanized_money_with_symbol(transaction[:payment_sum])), created_at: transition[:created_at], mood: :positive }
      else
        raise("Unknown transition to state: #{transaction[:to_state]}")
      end
    when "canceled"
      {sender: transaction[:author], content: t("conversations.message.canceled_#{direction}"), created_at: transition[:created_at], mood: :negative }
    when "confirmed"
      {sender: transaction[:author], content: t("conversations.message.confirmed_#{direction}"), created_at: transition[:created_at], mood: :positive }
    else
      raise("Unknown transition to state: #{transaction[:to_state]}")
    end
  end
end
