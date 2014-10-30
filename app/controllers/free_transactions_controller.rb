class FreeTransactionsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply

  skip_filter :dashboard_only

  ContactForm = FormUtils.define_form("ListingConversation", :content, :sender_id, :listing_id, :community_id)
    .with_validations { validates_presence_of :content, :listing_id }

  def new
    use_contact_view = @listing.status_after_reply == "free"
    @listing_conversation = new_contact_form

    if use_contact_view
      render "listing_conversations/contact", locals: {
        contact: false,
        contact_form: @listing_conversation,
        create_contact: create_contact_path(:person_id => @current_user.id, :listing_id => @listing.id)
      }
    end
  end

  def contact
    @listing_conversation = new_contact_form
    render "listing_conversations/contact", locals: {
      contact: true,
      contact_form: @listing_conversation,
      create_contact: create_contact_path(:person_id => @current_user.id, :listing_id => @listing.id)
    }
  end

  def create_contact
    contact_form = new_contact_form(params[:listing_conversation])

    if contact_form.valid?
      transaction_response = TransactionService::Transaction.create(
        {
          transaction: {
            community_id: @current_community.id,
            listing_id: contact_form.listing_id,
            starter_id: @current_user.id,
            listing_author_id: @listing.author.id,
            content: contact_form.content,
            payment_gateway: :none,
            payment_process: :none}
        })

      unless transaction_response[:success]
        flash[:error] = "Sending the message failed. Please try again."
        return redirect_to root
      end

      transaction_id = transaction_response[:data][:transaction][:id]
      MarketplaceService::Transaction::Command.transition_to(transaction_id, "free")

      # TODO: remove references to transaction model
      transaction = Transaction.find(transaction_id)

      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, @current_community.id))
      redirect_to session[:return_to_content] || root
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  private

  def ensure_listing_author_is_not_current_user
    if @listing.author == @current_user
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to (session[:return_to_content] || root)
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    unless @listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to root and return
    end
  end

  def ensure_listing_is_open
    if @listing.closed?
      flash[:error] = t("layouts.notifications.you_cannot_reply_to_a_closed_#{@listing.direction}")
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing_from_params
    @listing = Listing.find(params[:listing_id] || params[:id])
  end

  def new_contact_form(conversation_params = {})
    ContactForm.new(conversation_params.merge({sender_id: @current_user.id, listing_id: @listing.id, community_id: @current_community.id}))
  end

end
