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

    other = conversation[:other_person]
    conversation[:other_party] = person_entity_with_url(other)
    transaction[:listing_url] = listing_path(id: transaction[:listing][:id])

    # TODO Copy-paste code
    # Move to service
    transaction_type = TransactionType.find(transaction[:listing][:transaction_type_id])
    transaction[:new_transaction_path] = if transaction_type.price_per.present?
      book_path(:listing_id => transaction[:listing][:id])
    else
      preauthorize_payment_path(:listing_id => transaction[:listing][:id])
    end
    transaction[:action_button_label] = transaction_type.action_button_label(I18n.locale)

    not_author = transaction[:listing][:author_id] != @current_user.id
    requires_payment = transaction_type.price_field? && @current_community.payments_in_use?
    transaction[:show_call_to_action] = transaction[:status] == "free" && requires_payment && not_author


    messages_and_actions = TransactionViewUtils::merge_messages_and_transitions(
      TransactionViewUtils.conversation_messages(conversation[:messages]),
      TransactionViewUtils.transition_messages(transaction, conversation))

    MarketplaceService::Transaction::Command.mark_as_seen_by_current(params[:id], @current_user.id)

    render "transactions/show", locals: {
      messages: messages_and_actions.reverse,
      transaction_data: transaction,
      is_author: transaction[:listing][:author_id] == @current_user.id,
      message_form: MessageForm.new({sender_id: @current_user.id, conversation_id: conversation[:id]}),
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation[:id])
    }
  end

  def op_status
    process_token = params[:process_token]

    resp = Maybe(process_token)
      .map { |ptok| paypal_process.get_status(ptok) }
      .select(&:success)
      .data
      .or_else(nil)

    if resp
      render :json => resp
    else
      redirect_to error_not_found_path
    end
  end

  def person_entity_with_url(person_entity)
    person_entity.merge({url: person_path(id: person_entity[:username])})
  end

  def paypal_process
    PaypalService::API::Api.process
  end
end
