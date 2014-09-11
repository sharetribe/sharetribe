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

  skip_filter :dashboard_only

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

    messages = h[:messages].map(&:to_h).map { |message|
      sender = conversation_data[:participants].find { |participant| participant.id == message[:sender_id] }
      message.merge({mood: :neutral, type: :message}).merge(sender: sender)
    }

    render locals: {
      messages: messages.reverse,
      conversation_data: h,
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => h[:id])
    }
  end
end
