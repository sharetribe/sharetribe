class ConversationsController < ApplicationController
  include MoneyRails::ActionViewExtension

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  def show
    conversation_id = params[:id]

    conversation = Conversation.by_community(@current_community).for_person(@current_user).where(id: conversation_id).first

    if conversation.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to search_path
    end

    transaction = conversation.tx

    if transaction.present?
      # We do not want to use this controller to show conversations with transactions
      # as the transaction controller shows not only the messages, but also the actions
      # so redirect there.
      redirect_to person_transaction_url(@current_user, {:id => transaction.id}) and return
    end

    message_form = Message.new({sender_id: @current_user.id, conversation_id: conversation_id})

    messages = TransactionViewUtils.conversation_messages(conversation.messages.latest, @current_community.name_display_type)

    conversation.mark_as_read(@current_user.id)

    render locals: {
      messages: messages,
      conversation_data: conversation,
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation[:id])
    }
  end

end
