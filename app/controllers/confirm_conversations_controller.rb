class ConfirmConversationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_confirm_or_cancel")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_starter

  skip_filter :dashboard_only

  def confirm
    @action = "confirm"
  end

  def cancel
    @action = "cancel"
    render :confirm
  end

  # Handles confirm and cancel forms
  def confirmation
    status = params[:transaction][:status]

    if @listing_conversation.can_transition_to? status
      @listing_conversation.transition_to! status

      give_feedback = Maybe(params)[:give_feedback].select { |v| v == "true" }.or_else { false }

      confirmation = ConfirmConversation.new(@listing_conversation, @current_user, @current_community)
      confirmation.update_participation(give_feedback)

      flash[:notice] = t("layouts.notifications.#{@listing_conversation.listing.direction}_#{@listing_conversation.status}")

      redirect_path = if give_feedback
        new_person_message_feedback_path(:person_id => @current_user.id, :message_id => @listing_conversation.id)
      else
        person_message_path(:person_id => @current_user.id, :id => @listing_conversation.id)
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
