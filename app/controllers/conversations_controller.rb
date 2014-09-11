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

      current = conversation[:participants].select { |participant| participant.id == @current_user.id }.first
      other = conversation[:participants].reject { |participant| participant.id == @current_user.id }.first

      h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})
      h[:path] = single_conversation_path(:conversation_type => "received", :id => conversation.id)
      h[:read_by_current] = current.is_read

      messages = merge_messages_and_transitions(h[:messages], create_messages_from_actions(h[:transaction] || {}))

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

    # @current_user.read(conversation) unless conversation.read_by?(@current_user)

    message_form = MessageForm.new({sender_id: @current_user.id, conversation_id: conversation_id})

    h = conversation_data.to_h
    other = conversation_data[:participants].reject { |participant| participant.id == @current_user.id }.first
    h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})

    transaction = conversation_data[:transaction]

    h[:listing_url] = if transaction
      listing_path(id: transaction[:listing][:id])
    end

    # transitions = if transaction
    #   transaction[:transitions].map do |transition|
    #     MarketplaceService::Conversation::Entity.add_actor_to_transition(transaction, transition)
    #   end
    # else
    #   []
    # end

    messages = h[:messages].map(&:to_h).map { |message| message.merge({mood: :neutral}) }

    messages = merge_messages_and_transitions(messages, create_messages_from_actions(h[:transaction] || {}))

    binding.pry

    render locals: {
      messages: messages,
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
    direction = transaction.direction
    author_id = transaction[:listing][:author_id]
    starter_id = transaction[:starter_id]

    case transition[:to_state]
    when "preauthorized"
      {sender_id: starter_id, content: t("conversations.message.paid", sum: humanized_money_with_symbol(transaction.payment_sum)), created_at: transition[:created_at], mood: :positive }
    when "accepted"
      {sender_id: author_id, content: t("conversations.message.accepted_#{direction}"), created_at: transition[:created_at], mood: :positive }
    when "rejected"
      {sender_id: author_id, content: t("conversations.message.rejected_#{direction}"), created_at: transition[:created_at], mood: :negative }
    when "paid" && old_state == "preauthorized"
      {sender_id: author_id, content: t("conversations.message.accepted_#{direction}"), created_at: transition[:created_at], mood: :positive }
    when "paid" && old_state == "accepted"
      {sender_id: starter_id, content: t("conversations.message.paid", sum: humanized_money_with_symbol(transaction.payment_sum)), created_at: transition[:created_at], mood: :positive }
    when "canceled"
      {sender_id: author_id, content: t("conversations.message.canceled_#{direction}"), created_at: transition[:created_at], mood: :negative }
    when "confirmed"
      {sender_id: author_id, content: t("conversations.message.confirmed_#{direction}"), created_at: transition[:created_at], mood: :positive }
    else
      raise("Unknown transition to state: #{transaction[:to_state]}")
    end
  end

  def map_conversation(conversation)
    h = {}

    transaction = Maybe(conversation).transaction
    payment_sum = transaction.payment.total_sum.or_else { nil }

    last_message_content = if conversation.last_message.action == "pay"
      t("conversations.message.paid", :sum => humanized_money_with_symbol(payment_sum))
    elsif conversation.last_message.action.present?
      t("conversations.message.#{conversation.last_message.action}ed_#{transaction.discussion_type.get}").capitalize
    else
      conversation.last_message.content
    end

    # For some reason, other_party was wrapped inside "if". I guess there might be situations where other_party do
    # not exist. This is error in data. Anyway, we don't want the whole inbox to break because of this.
    h[:other_party] = Maybe(conversation).other_party(@current_user).map { |other_party|
      {
        name: other_party.name,
        avatar: other_party.image.url(:thumb),
        url: url_for(other_party)
      }
    }.or_else { nil }
    h[:read_by_current] = conversation.read_by?(@current_user)
    h[:last_message_sender_is_current_user] = conversation.last_message.sender == @current_user
    h[:last_message_content] = last_message_content
    h[:last_message_ago] = time_ago(conversation.last_message_at)
    h[:path_to_conversation] = single_conversation_path(:conversation_type => action_name, :id => conversation.id)


    h[:transaction] = transaction.map { |txn|
      listing = transaction.listing

      {
        model: txn, # TODO remove the reference to the model
        # TODO Move feedback from conversation participants to transaction
        waiting_feedback_from_current: false, # transaction.waiting_feedback_from?(@current_user).or_else { nil }
        is_author: txn.author == @current_user,
        status: txn.status,
        listing: listing.map { |l|
          {title: l.title, url: url_for(l) }
        }.or_else { nil },
        reply_to_listing_path: reply_to_listing_path(:listing_id => listing.id),
        action_button_label: listing.transaction_type.action_button_label(I18n.locale)
      }
    }.or_else { nil }

    h
  end
end
