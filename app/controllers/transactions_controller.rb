class TransactionsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  MessageForm = Form::Message

  def show
    transaction = MarketplaceService::Transaction::Query.transaction_with_conversation(
      params[:id],
      @current_user.id,
      @current_community.id)

    if transaction.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to root
    end

    conversation = transaction[:conversation]

    other = MarketplaceService::Conversation::Entity.other_by_id(conversation, @current_user.id)
    conversation[:other_party] = person_entity_with_url(other)

    messages_and_actions = TransactionViewUtils::merge_messages_and_transitions(
      TransactionViewUtils.conversation_messages(conversation[:messages]),
      TransactionViewUtils.transition_messages(transaction, conversation))

    MarketplaceService::Conversation::Command.mark_as_read(conversation[:id], @current_user.id)

    render "transactions/show", locals: {
      messages: messages_and_actions.reverse,
      transaction_data: transaction,
      message_form: MessageForm.new({sender_id: @current_user.id, conversation_id: conversation[:id]}),
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation[:id])
    }
  end

  def person_entity_with_url(person_entity)
    person_entity.merge({url: person_path(id: person_entity[:username])})
  end
end
