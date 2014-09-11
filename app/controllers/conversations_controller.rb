class ConversationsController < ApplicationController
  include MoneyRails::ActionViewExtension

  MessageForm = FormUtils.define_form("Message",
    :content,
    :conversation_id, # TODO Remove this
    :sender_id, # TODO Remove this
  ).with_validations {
    validates_presence_of :content, :conversation_id, :sender_id
  }


  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  def index
    redirect_to received_person_messages_path(:person_id => @current_user.id)
  end

  def received
    params[:page] = 1 unless request.xhr?

    conversation_data = MarketplaceService::Conversation::Query.conversations_and_transactions(
      @current_user.id,
      @current_community.id,
      {per_page: 15, page: params[:page]})

    # conversation_data = conversation_models.map(&method(:map_conversation))

    conversation_data = conversation_data.map { |conversation|
      h = conversation.to_h

      current = conversation[:participants].select { |participant| participant[:id] == @current_user.id }.first
      other = conversation[:participants].reject { |participant| participant[:id] == @current_user.id }.first

      h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})
      h[:path] = single_conversation_path(:conversation_type => "received", :id => conversation.id)
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
        h[:waiting_feedback_from_current] = MarketplaceService::Conversation::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id)
      end

      h
    }

    if request.xhr?
      render :partial => "additional_messages"
    else
      render :action => :index, locals: {
        conversation_data: conversation_data
      }
    end
  end

  def show
    conversation_id = params[:id]

    conversation_data = MarketplaceService::Conversation::Query.conversation_for_person(
      conversation_id,
      @current_user.id,
      @current_community.id)

    if conversation_data.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to root
    end

    # TODO MARK AS READ!
    # @current_user.read(conversation) unless conversation.read_by?(@current_user)

    message_form = MessageForm.new({sender_id: @current_user.id, conversation_id: conversation_id})

    h = conversation_data.to_h
    other = conversation_data[:participants].reject { |participant| participant.id == @current_user.id }.first
    h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})

    transaction = conversation_data[:transaction]

    h[:listing_url] = if transaction
      listing_path(id: transaction[:listing][:id])
    end

    messages = h[:messages].map(&:to_h).map { |message|
      sender = conversation_data[:participants].find { |participant| participant.id == message[:sender_id] }
      message.merge({mood: :neutral}).merge(sender: sender)
    }

    transaction = if h[:transaction].present?
      transaction = h[:transaction].to_h
      author_id = transaction[:listing][:author_id]
      starter_id = transaction[:starter_id]

      author = conversation_data[:participants].find { |participant| participant.id == author_id }
      starter = conversation_data[:participants].find { |participant| participant.id == starter_id }

      author_url = {url: person_path(id: author[:username])}
      starter_url = {url: person_path(id: starter[:username])}

      transaction.merge({author: author, starter: starter})
    else
      {}
    end

    messages_and_actions = merge_messages_and_transitions(messages, create_messages_from_actions(transaction))

    render locals: {
      messages: messages_and_actions.reverse,
      conversation_data: h,
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => h[:id])
    }
  end

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
    when "paid" && old_state == "preauthorized"
      {sender: transaction[:author], content: t("conversations.message.accepted_#{direction}"), created_at: transition[:created_at], mood: :positive }
    when "paid" && old_state == "accepted"
      {sender: transaction[:starter], content: t("conversations.message.paid", sum: humanized_money_with_symbol(transaction[:payment_sum])), created_at: transition[:created_at], mood: :positive }
    when "canceled"
      {sender: transaction[:author], content: t("conversations.message.canceled_#{direction}"), created_at: transition[:created_at], mood: :negative }
    when "confirmed"
      {sender: transaction[:author], content: t("conversations.message.confirmed_#{direction}"), created_at: transition[:created_at], mood: :positive }
    else
      raise("Unknown transition to state: #{transaction[:to_state]}")
    end
  end
end
