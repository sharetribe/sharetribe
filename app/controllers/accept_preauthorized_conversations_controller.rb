class AcceptPreauthorizedConversationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_author

  skip_filter :dashboard_only

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token

  def accept
    @action = "paid"
    binding.pry
  end

  def reject
    @action = "rejected"
    render :accept
    binding.pry
  end

# Handles accept and reject forms
  def acceptance
    binding.pry
    if @listing_conversation.update_attributes(params[:listing_conversation])
      flash[:notice] = t("layouts.notifications.#{@listing_conversation.discussion_type}_#{@listing_conversation.status}")
      redirect_to person_message_path(:person_id => @current_user.id, :id => @listing_conversation.id)
    else
      flash[:error] = t("layouts.notifications.something_went_wrong")
      redirect_to person_message_path(@current_user, @listing_conversation)
    end
  end

  private

  def ensure_is_author
    unless @listing.author == @current_user
      flash[:error] = "Only listing author can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing
    @listing = @listing_conversation.listing
  end

  def fetch_conversation
    binding.pry
    @listing_conversation = ListingConversation.find(params[:id])
  end
end