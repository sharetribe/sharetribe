class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension

  skip_filter :dashboard_only

  def show
    params[:page] = 1 unless request.xhr?

    conversation_data = MarketplaceService::Conversation::Query.conversations_and_transactions(
      @current_user.id,
      @current_community.id,
      {per_page: 15, page: params[:page]})

    conversation_data = conversation_data.map { |conversation|
      h = conversation.to_h

      current = conversation[:participants].select { |participant| participant[:id] == @current_user.id }.first
      other = conversation[:participants].reject { |participant| participant[:id] == @current_user.id }.first

      h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})

      h[:path] = if h[:transaction].present?
        person_transaction_path(:person_id => @current_user.username, :id => h[:transaction][:id])
      else
        single_conversation_path(:conversation_type => "received", :id => conversation.id)
      end

      h[:read_by_current] = current.is_read

      transaction = if h[:transaction].present?
        transaction = h[:transaction].to_h
        author_id = transaction[:listing][:author_id]
        starter_id = transaction[:starter_id]

        author = h[:participants].find { |participant| participant[:id] == author_id }
        starter = h[:participants].find { |participant| participant[:id] == starter_id }

        author_url = {url: person_path(id: author[:username])}
        starter_url = {url: person_path(id: starter[:username])}

        transaction.merge({author: author, starter: starter})
      else
        {}
      end

      messages = merge_messages_and_transitions(h[:messages], create_messages_from_actions(transaction || {}))

      h[:title] = messages.last[:content]
      h[:last_update_at] = time_ago(messages.last[:created_at])

      h[:listing_url] = if conversation.transaction
        listing_path(id: conversation.transaction.listing.id)
      end

      if conversation[:transaction]
        h[:is_transaction_author] = conversation[:transaction][:listing][:author_id] == @current_user.id
        h[:waiting_feedback_from_current] = MarketplaceService::Transaction::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id)
      end

      h
    }

    if request.xhr?
      # TODO Make sure these work
      render :partial => "additional_messages"
    else
      render :action => :show, locals: {
        conversation_data: conversation_data
      }
    end
  end

  private

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
      ["free", "pending"].include? transition.to_state
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
