class ConversationsController < ApplicationController
  include MoneyRails::ActionViewExtension

  MessageForm = Form::Message

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  skip_filter :dashboard_only

  def show
    conversation_id = params[:id]

    conversation = MarketplaceService::Conversation::Query.conversation_for_person(
      conversation_id,
      @current_user.id,
      @current_community.id)

    if conversation.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to root
    end

    transaction = Transaction.find_by_conversation_id(conversation[:id])

    if transaction.present?
      # We do not want to use this controller to show conversations with transactions
      # as the transaction controller shows not only the messages, but also the actions
      # so redirect there.
      redirect_to person_transaction_url(@current_user, {:id => transaction.id}) and return
    end

    message_form = MessageForm.new({sender_id: @current_user.id, conversation_id: conversation_id})

    other = conversation[:other_person]
    conversation[:other_party] = person_entity_with_url(other)

    messages = TransactionViewUtils.conversation_messages(conversation[:messages])

    MarketplaceService::Conversation::Command.mark_as_read(conversation[:id], @current_user.id)

    render locals: {
      messages: messages.reverse,
      conversation_data: conversation,
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation[:id])
    }
  end

  def person_entity_with_url(person_entity)
    person_entity.merge({url: person_path(id: person_entity[:username])})
  end
end
