class FreeTransactionsController < ApplicationController

  before_action do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_action :fetch_listing_from_params
  before_action :ensure_listing_is_open
  before_action :ensure_listing_author_is_not_current_user
  before_action :ensure_authorized_to_reply

  ContactForm = FormUtils.define_form("ListingConversation", :content, :sender_id, :listing_id, :community_id)
    .with_validations { validates_presence_of :content, :listing_id }

  def new
    render_contact_form
  end

  def contact
    render_contact_form
  end

  def create_contact
    contact_form = new_contact_form(params[:listing_conversation])

    if contact_form.valid?
      transaction_response = TransactionService::Transaction.create(
        {
          transaction: {
            community_id: @current_community.id,
            community_uuid: @current_community.uuid_object,
            listing_id: @listing.id,
            listing_uuid: @listing.uuid_object,
            listing_title: @listing.title,
            starter_id: @current_user.id,
            starter_uuid: @current_user.uuid_object,
            listing_author_id: @listing.author.id,
            listing_author_uuid: @listing.author.uuid_object,
            unit_type: @listing.unit_type,
            unit_price: @listing.price,
            unit_tr_key: @listing.unit_tr_key,
            availability: :none, # Always none for free transactions and contacts
            listing_quantity: 1,
            content: contact_form.content,
            starting_page: ::Conversation::LISTING,
            payment_gateway: :none,
            payment_process: :none}
        })

      unless transaction_response[:success]
        flash[:error] = t("layouts.notifications.message_not_sent")
        return redirect_to search_path
      end

      transaction_id = transaction_response[:data][:transaction][:id]
      TransactionService::StateMachine.transition_to(transaction_id, "free")

      transaction = Transaction.find(transaction_id)

      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, @current_community.id))
      redirect_to session[:return_to_content] || search_path
    else
      flash[:error] = t("layouts.notifications.message_not_sent")
      redirect_to search_path
    end
  end

  private

  def render_contact_form
    @listing_conversation = new_contact_form
    render "listing_conversations/contact", locals: {
      contact_form: @listing_conversation,
      create_contact: create_contact_path(:person_id => @current_user.id, :listing_id => @listing.id)
    }
  end

  def ensure_listing_author_is_not_current_user
    if @listing.author == @current_user
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to (session[:return_to_content] || search_path)
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    unless @listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to search_path and return
    end
  end

  def ensure_listing_is_open
    if @listing.closed?
      flash[:error] = t("layouts.notifications.you_cannot_reply_to_a_closed_offer")
      redirect_to (session[:return_to_content] || search_path)
    end
  end

  def fetch_listing_from_params
    @listing = Listing.find(params[:listing_id] || params[:id])
  end

  def new_contact_form(conversation_params = {})
    ContactForm.new(conversation_params.merge({sender_id: @current_user.id, listing_id: @listing.id, community_id: @current_community.id}))
  end

end
