class ConversationsController < ApplicationController
  include MoneyRails::ActionViewExtension

  MessageForm = Form::Message

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

    MarketplaceService::Conversation::Command.mark_as_read(conversation_data[:id], @current_user.id)

    message_form = MessageForm.new({sender_id: @current_user.id, conversation_id: conversation_id})

    other = conversation_data[:participants].reject { |participant| participant[:id] == @current_user.id }.first

    conversation_data[:other_party] = other.merge({url: person_path(id: other[:username])})

    messages = conversation_data[:messages].map { |message|
      sender = conversation_data[:participants].find { |participant| participant[:id] == message[:sender_id] }
      message.merge({mood: :neutral, type: :message}).merge(sender: sender)
    }

    render locals: {
      messages: messages.reverse,
      conversation_data: conversation_data,
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation_data[:id])
    }
  end
end
