class ConfirmConversationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_confirm_or_cancel")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_starter

  skip_filter :dashboard_only

  MessageForm = Form::Message

  def confirm
    unless in_valid_pre_state(@listing_transaction)
      return redirect_to person_transaction_path(person_id: @current_user.id, message_id: @listing_transaction.id)
    end

    conversation =      MarketplaceService::Conversation::Query.conversation_for_person(@listing_transaction.conversation.id, @current_user.id, @current_community.id)
    can_be_confirmed =  MarketplaceService::Transaction::Query.can_transition_to?(@listing_transaction, :confirmed)
    other_person =      MarketplaceService::Person::Query.person(@listing_transaction.other_party(@current_user), @current_community.id)

    render(locals: {
      action_type: "confirm",
      message_form: MessageForm.new,
      listing_transaction: @listing_transaction,
      can_be_confirmed: can_be_confirmed,
      other_person: other_person,
      status: @listing_transaction.status,
      form: @listing_transaction # TODO fix me, don't pass objects
    })
  end

  def cancel
    unless in_valid_pre_state(@listing_transaction)
      return redirect_to person_transaction_path(person_id: @current_user.id, message_id: @listing_transaction.id)
    end

    conversation =      MarketplaceService::Conversation::Query.conversation_for_person(@listing_transaction.conversation.id, @current_user.id, @current_community.id)
    can_be_confirmed =  MarketplaceService::Transaction::Query.can_transition_to?(@listing_transaction.id, :confirmed)
    other_person =      MarketplaceService::Person::Query.person(@listing_transaction.other_party(@current_user), @current_community.id)

    render(:confirm, locals: {
      action_type: "cancel",
      message_form: MessageForm.new,
      listing_transaction: @listing_transaction,
      can_be_confirmed: can_be_confirmed,
      other_person: other_person,
      status: @listing_transaction.status,
      form: @listing_transaction # TODO fix me, don't pass objects
    })
  end

  # TODO: Separate confirm and cancel form handling to separate actions
  # Handles confirm and cancel forms
  def confirmation
    status = params[:transaction][:status]

    if MarketplaceService::Transaction::Query.can_transition_to?(@listing_transaction.id, status)

      transaction =
        if status.to_sym == :confirmed
          TransactionService::Transaction.complete(@listing_transaction.id)
        else
          TransactionService::Transaction.cancel(@listing_transaction.id)
        end

      if(params[:message])
        message = MessageForm.new(params[:message].merge({ sender_id: @current_user.id, conversation_id: @listing_transaction.conversation.id }))
        if(message.valid?)
          @listing_transaction.conversation.messages.create({ content: message.content, sender_id: message.sender_id})
        end
      end

      give_feedback = Maybe(params)[:give_feedback].select { |v| v == "true" }.or_else { false }

      confirmation = ConfirmConversation.new(@listing_transaction, @current_user, @current_community)
      confirmation.update_participation(give_feedback)

      flash[:notice] = t("layouts.notifications.#{@listing_transaction.listing.direction}_#{status}")

      redirect_path =
        if give_feedback
          new_person_message_feedback_path(:person_id => @current_user.id, :message_id => @listing_transaction.id)
        else
          person_transaction_path(:person_id => @current_user.id, :id => @listing_transaction.id)
        end

      redirect_to redirect_path
    else
      flash[:error] = t("layouts.notifications.something_went_wrong")
      redirect_to person_transaction_path(person_id: @current_user.id, message_id: @listing_transaction.id)
    end
  end

  private

  def ensure_is_starter
    unless @listing_transaction.starter == @current_user
      flash[:error] = "Only listing starter can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing
    @listing = @listing_transaction.listing
  end

  def fetch_conversation
    @listing_transaction = @current_community.transactions.find(params[:id])
  end

  def in_valid_pre_state(transaction)
    transaction.can_be_confirmed? || transaction.can_be_canceled?
  end
end
