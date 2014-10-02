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
    @action = "confirm"
    render(locals: { message_form: MessageForm.new })
  end

  def cancel
    @action = "cancel"
    render(:confirm, locals: { message_form: MessageForm.new })
  end

  # TODO: Separate confirm and cancel form handling to separate actions
  # Handles confirm and cancel forms
  def confirmation
    status = params[:transaction][:status]

    if MarketplaceService::Transaction::Query.can_transition_to?(@listing_conversation.id, status)
      MarketplaceService::Transaction::Command.transition_to(@listing_conversation.id, status)
      MarketplaceService::Transaction::Command.mark_as_unseen_by_other(@listing_conversation.id, @current_user.id)

      if(params[:message])
        message = MessageForm.new(params[:message].merge({ sender_id: @current_user.id, conversation_id: @listing_conversation.id }))
        if(message.valid?)
          @listing_conversation.conversation.messages.create({ content: message.content, sender_id: message.sender_id})
        end
      end

      give_feedback = Maybe(params)[:give_feedback].select { |v| v == "true" }.or_else { false }

      confirmation = ConfirmConversation.new(@listing_conversation, @current_user, @current_community)
      confirmation.update_participation(give_feedback)

      flash[:notice] = t("layouts.notifications.#{@listing_conversation.listing.direction}_#{status}")

      redirect_path = if give_feedback
        new_person_message_feedback_path(:person_id => @current_user.id, :message_id => @listing_conversation.id)
      else
        person_transaction_path(:person_id => @current_user.id, :id => @listing_conversation.id)
      end

      redirect_to redirect_path
    else
      flash.now[:error] = t("layouts.notifications.something_went_wrong")
      render :edit
    end
  end

  private

  def ensure_is_starter
    unless @listing_conversation.starter == @current_user
      flash[:error] = "Only listing starter can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing
    @listing = @listing_conversation.listing
  end

  def fetch_conversation
    @listing_conversation = @current_community.transactions.find(params[:id])
  end
end
