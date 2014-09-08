class ListingConversationsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply
  before_filter :ensure_can_receive_payment, only: [:preauthorize, :preauthorized]

  skip_filter :dashboard_only

  BookingForm = Util::FormUtils.define_form("BookingForm", :start_on, :end_on)
    .with_validations do
      validates :start_on, :end_on, presence: true
      validates_date :start_on, on_or_after: :today
      validates_date :end_on, on_or_after: :start_on
    end

  ContactForm = Util::FormUtils.define_form("ListingConversation", :content, :sender_id, :listing_id, :community_id)
    .with_validations { validates_presence_of :content, :listing_id }

  BraintreeForm = Util::FormUtils.define_form("ListingConversation",
    :braintree_cardholder_name,
    :braintree_credit_card_number,
    :braintree_cvv,
    :braintree_credit_card_expiration_month,
    :braintree_payment_credit_card_expiration_year
  ).with_validations {
    # TODO ADD VALIDATIONS
  }

  PreauthorizeMessageForm = Util::FormUtils.define_form("ListingConversation",
    :content,
    :sender_id,
    :contract_agreed
  ).with_validations { validates_presence_of :content, :listing_id }

  PreauthorizeForm = Util::FormUtils.merge("ListingConversation", BookingForm, BraintreeForm, PreauthorizeMessageForm)

  def new
    use_contact_view = @listing.status_after_reply == "free"
    @listing_conversation = new_contact_form

    if use_contact_view
      render :contact, locals: {
        contact: false,
        contact_form: @listing_conversation
      }
    else
      render :new_with_payment, locals: {
        contact_form: @listing_conversation,
        listing: @listing
      }
    end
  end

  def preauthorize
    booking_form = if @listing.transaction_type.price_per.present?
      BookingForm.new({
        start_on: params[:start_on],
        end_on: params[:end_on]
      })
    end

    if booking_form.present? && !booking_form.valid?
      flash[:error] = booking_form.errors.full_messages
      redirect_to @listing and return
    end

    @braintree_client_side_encryption_key = @current_community.payment_gateway.braintree_client_side_encryption_key

    preauthorize_form = PreauthorizeForm.new({
      start_on: Maybe(booking_form).start_on.or_else(nil),
      end_on: Maybe(booking_form).end_on.or_else(nil),
      sender_id: @current_user.id
    })

    sum = Maybe(booking_form).map { |booking|
      @listing.price * duration(booking.start_on, booking.end_on)
    }.or_else {
      @listing.price
    }

    render locals: {
      preauthorize_form: preauthorize_form,
      booking_form: booking_form,
      listing: @listing,
      sum: sum,
      author: @listing.author
    }
  end

  def preauthorized
    conversation_params = params[:listing_conversation]

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      flash[:error] = "Agreement checkbox has to be selected"
      return redirect_to action: :preauthorize
    end

    binding.pry
    preauthorize_form = PreauthorizeForm.new(conversation_params)

    if preauthorize_form.valid?
      transaction = Transaction.new({
        community_id: @current_community.id,
        listing_id: @listing.id,
        starter_id: @current_user.id,
      });

      # TODO MESSAGES HERE!

      # TODO JATKA TÄSTÄ

    else
      flash[:error] = preauthorize_form.errors.full_messages.join(", ")
      return redirect_to action: :preauthorize
    end

    @payment = @listing_conversation.initialize_payment

    # def initialize_payment
    #   payment ||= community.payment_gateway.new_payment
    #   payment.payment_gateway ||= community.payment_gateway
    #   payment.conversation = self
    #   payment.status = "pending"
    #   payment.payer = starter
    #   payment.recipient = author
    #   payment.community = community
    #   payment
    # end

    @payment.sum = @listing_conversation.calculate_total

    pay(@current_user, @listing_conversation, @payment)
  end

  def pay(payer, listing_conversation, payment)
    result = BraintreeSaleService.new(payment, params[:braintree_payment]).pay(false)
    recipient = payment.recipient

    if result.success?
      @listing_conversation.save!
      listing_conversation.status = "preauthorized"
      redirect_to person_message_path(:id => listing_conversation.id)
    else
      flash[:error] = result.message
      redirect_to action: :preauthorize
    end
  end

  def contact
    @listing_conversation = new_contact_form
    render :contact, locals: {contact: true, contact_form: @listing_conversation}
  end

  def create
    contact_form = new_contact_form(params[:listing_conversation])

    if contact_form.valid?
      transaction = Transaction.new({
        community_id: @current_community.id,
        listing_id: @listing.id,
        starter_id: @current_user.id,
      });

      conversation = transaction.build_conversation(community_id: @current_community.id, listing_id: @listing.id)

      conversation.messages.build({
        content: contact_form.content,
        sender_id: contact_form.sender_id
      })

      conversation.participations.build({
        person_id: @listing.author.id,
        is_starter: false
      })

      conversation.participations.build({
        person_id: @current_user.id,
        is_starter: true,
        is_read: true
      })

      transaction.save!

      binding.pry
      transaction.status = @listing.status_after_reply

      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, @current_community.id))
      redirect_to session[:return_to_content] || root
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  def create_contact
    contact_form = new_contact_form(params[:listing_conversation])

    if contact_form.valid?
      transaction = Transaction.new({
        community_id: @current_community.id,
        listing_id: @listing.id,
        starter_id: @current_user.id,
      });

      conversation = transaction.build_conversation(community_id: @current_community.id, listing_id: @listing.id)

      conversation.messages.build({
        content: contact_form.content,
        sender_id: contact_form.sender_id
      })

      conversation.participations.build({
        person_id: @listing.author.id,
        is_starter: false
      })

      conversation.participations.build({
        person_id: @current_user.id,
        is_starter: true,
        is_read: true
      })

      transaction.save!
      transaction.status = "free"

      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, @current_community.id))
      redirect_to session[:return_to_content] || root
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  private

  def save_conversation(params)
    @listing_conversation = new_conversation(params)
    if @listing_conversation.save
      @listing_conversation
    else
      nil
    end
  end

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

  def new_conversation(conversation_params = {})
    Transaction.new(conversation_params.merge(community: @current_community, listing: @listing, starter: @current_user))
  end

  def new_contact_form(conversation_params = {})
    ContactForm.new(conversation_params.merge({sender_id: @current_user.id, listing_id: @listing.id, community_id: @current_community.id}))
  end

  def ensure_can_receive_payment
    Maybe(@current_community).payment_gateway.each do |gateway|
      unless gateway.can_receive_payments?(@listing.author)
        flash[:error] = t("layouts.notifications.listing_author_payment_details_missing")
        redirect_to (session[:return_to_content] || root)
      end
    end
  end

  def duration(start_on, end_on)
    (end_on - start_on).to_i + 1
  end
end
