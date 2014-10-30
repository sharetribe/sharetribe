class PreauthorizeTransactionsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply
  before_filter :ensure_can_receive_payment, only: [:preauthorize, :preauthorized]

  skip_filter :dashboard_only

  BookingForm = FormUtils.define_form("BookingForm", :start_on, :end_on)
    .with_validations do
      validates :start_on, :end_on, presence: true
      validates_date :start_on, on_or_after: :today
      validates_date :end_on, on_or_after: :start_on
    end

  ContactForm = FormUtils.define_form("ListingConversation", :content, :sender_id, :listing_id, :community_id)
    .with_validations { validates_presence_of :content, :listing_id }

  BraintreeForm = Form::Braintree

  PreauthorizeMessageForm = FormUtils.define_form("ListingConversation",
    :content,
    :sender_id,
    :contract_agreed,
    :listing_id
  ).with_validations { validates_presence_of :listing_id }

  PreauthorizeBookingForm = FormUtils.merge("ListingConversation", PreauthorizeMessageForm, BookingForm)

  ListingQuery = MarketplaceService::Listing::Query
  PersonQuery = MarketplaceService::Person::Query
  BraintreePaymentQuery = BraintreeService::Payments::Query


  def initiate
    listing = ListingQuery.listing_with_transaction_type(params[:listing_id])
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)

    action_button_label = listing[:transaction_type][:action_button_label_translations]
      .select {|translation| translation[:locale] == I18n.locale}
      .first

    render "listing_conversations/initiate", locals: {
      preauthorize_form: PreauthorizeMessageForm.new,
      listing: listing,
      sum: listing[:price],
      author: PersonQuery.person(listing[:author_id]),
      action_button_label: action_button_label,
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(payment_type),
      form_action: initiated_order_path(person_id: @current_user.id, listing_id: listing[:id])
    }
  end

  def initiated
    conversation_params = params[:listing_conversation]

    preauthorize_form = PreauthorizeMessageForm.new(conversation_params.merge({
      listing_id: @listing.id
    }))

    unless preauthorize_form.valid?
      flash[:error] = preauthorize_form.errors.full_messages.join(", ")
      return redirect_to action: :initiate
    end

    # PayPal doesn't like images with cache buster in the URL
    logo_url = Maybe(@current_community)
      .wide_logo
      .select { |wl| wl.present? }
      .url(:paypal, timestamp: false)
      .or_else(nil)

    transaction_response = TransactionService::Transaction.create({
        transaction: {
          community_id: @current_community.id,
          listing_id: preauthorize_form.listing_id,
          starter_id: @current_user.id,
          listing_author_id: @listing.author.id,
          content: preauthorize_form.content,
          payment_gateway: :paypal,
          payment_process: :preauthorize,
          commission_from_seller: @current_community.commission_from_seller
        },
        gateway_fields: {
          merchant_brand_logo_url: logo_url,
          success_url: success_paypal_service_checkout_orders_url,
          cancel_url: cancel_paypal_service_checkout_orders_url(listing_id: @listing.id)
        }
      })

    unless transaction_response[:success]
      flash[:error] = t("error_messages.paypal.generic_error")
      return redirect_to action: :initiate
    end

    transaction_id = transaction_response[:data][:transaction][:id]

    MarketplaceService::Transaction::Command.transition_to(transaction_id, "initiated")
    redirect_to transaction_response[:data][:gateway_fields][:redirect_url]
  end

  def book
    listing = ListingQuery.listing_with_transaction_type(params[:listing_id])
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)
    booking_data = verified_booking_data(params[:start_on], params[:end_on])

    if booking_data[:error].present?
      flash[:error] = booking_data[:error]
      return redirect_to listing_path(listing[:id])
    end

    action_button_label = listing[:transaction_type][:action_button_label_translations]
      .select {|translation| translation[:locale] == I18n.locale}
      .first

    if @current_community.paypal_enabled?
      render "listing_conversations/initiate", locals: {
        preauthorize_form: PreauthorizeBookingForm.new({
          start_on: booking_data[:start_on],
          end_on: booking_data[:end_on]
        }),
        listing: listing,
        sum: listing[:price] * booking_data[:duration],
        duration: booking_data[:duration],
        author: PersonQuery.person(listing[:author_id]),
        action_button_label: action_button_label,
        expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(payment_type),
        form_action: initiated_order_path(person_id: @current_user.id, listing_id: listing[:id])
      }
    else
      braintree_settings = BraintreePaymentQuery.braintree_settings(@current_community.id)

      render "listing_conversations/preauthorize", locals: {
        preauthorize_form: PreauthorizeBookingForm.new({
          start_on: booking_data[:start_on],
          end_on: booking_data[:end_on]
        }),
        listing: listing,
        sum: listing[:price] * booking_data[:duration],
        duration: booking_data[:duration],
        author: PersonQuery.person(listing[:author_id]),
        action_button_label: action_button_label,
        expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(payment_type),
        braintree_client_side_encryption_key: braintree_settings[:braintree_client_side_encryption_key],
        braintree_form: BraintreeForm.new,
        form_action: booked_path(person_id: @current_user.id, listing_id: listing[:id])
      }

    end

  end

  def preauthorize
    listing = ListingQuery.listing_with_transaction_type(params[:listing_id])
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)
    action_button_label = listing[:transaction_type][:action_button_label_translations]
      .select {|translation| translation[:locale] == I18n.locale}
      .first

    braintree_settings = BraintreePaymentQuery.braintree_settings(@current_community.id)

    # TODO listing_conversations view (folder) needs some brainstorming
    render "listing_conversations/preauthorize", locals: {
      preauthorize_form: PreauthorizeMessageForm.new,
      braintree_client_side_encryption_key: braintree_settings[:braintree_client_side_encryption_key],
      braintree_form: BraintreeForm.new,
      listing: listing,
      sum: listing[:price],
      author: PersonQuery.person(listing[:author_id]),
      action_button_label: action_button_label,
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(payment_type),
      form_action: preauthorized_payment_path(person_id: @current_user.id, listing_id: listing[:id])
    }
  end

  def preauthorized
    conversation_params = params[:listing_conversation]

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      flash[:error] = "Agreement checkbox has to be selected"
      return redirect_to action: :preauthorize
    end

    preauthorize_form = PreauthorizeMessageForm.new(conversation_params.merge({
      listing_id: @listing.id
    }))

    if preauthorize_form.valid?
      braintree_form = BraintreeForm.new(params[:braintree_payment])

      transaction_response = TransactionService::Transaction.create({
          transaction: {
            community_id: @current_community.id,
            listing_id: preauthorize_form.listing_id,
            starter_id: @current_user.id,
            listing_author_id: @listing.author.id,
            content: preauthorize_form.content,
            payment_gateway: :braintree,
            payment_process: :preauthorize,
            commission_from_seller: @current_community.commission_from_seller
          },
          gateway_fields: braintree_form.to_hash
        })

      unless transaction_response[:success]
        flash[:error] = "An error occured while trying to create a new transaction: #{transaction_response[:error_msg]}"
        return redirect_to action: :preauthorize
      end

      transaction_id = transaction_response[:data][:transaction][:id]

      MarketplaceService::Transaction::Command.transition_to(transaction_id, "preauthorized")
      redirect_to person_transaction_path(:person_id => @current_user.id, :id => transaction_id)
    else
      flash[:error] = preauthorize_form.errors.full_messages.join(", ")
      return redirect_to action: :preauthorize
    end
  end

  def booked
    conversation_params = params[:listing_conversation]

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      flash[:error] = "Agreement checkbox has to be selected"
      return redirect_to action: :preauthorize
    end

    start_on = DateUtils.from_date_select(conversation_params, :start_on)
    end_on = DateUtils.from_date_select(conversation_params, :end_on)

    preauthorize_form = PreauthorizeBookingForm.new({
      braintree_cardholder_name: conversation_params[:braintree_cardholder_name],
      braintree_credit_card_number: conversation_params[:braintree_credit_card_number],
      braintree_cvv: conversation_params[:braintree_cvv],
      braintree_credit_card_expiration_month: conversation_params[:braintree_credit_card_expiration_month],
      braintree_credit_card_expiration_year: conversation_params[:braintree_credit_card_expiration_year],
      start_on: start_on,
      end_on: end_on,
      listing_id: @listing.id
    })

    if preauthorize_form.valid?
      braintree_form = BraintreeForm.new(params[:braintree_payment])

      transaction_response = TransactionService::Transaction.create({
          transaction: {
            community_id: @current_community.id,
            listing_id: @listing.id,
            starter_id: @current_user.id,
            listing_author_id: @listing.author.id,
            listing_quantity: DateUtils.duration_days(preauthorize_form.start_on, preauthorize_form.end_on),
            payment_gateway: MarketplaceService::Community::Query.payment_type(@current_community.id) || :none,
            payment_process: :preauthorize,
            commission_from_seller: @current_community.commission_from_seller,
            content: preauthorize_form.content,
            booking_fields: {
              start_on: preauthorize_form.start_on,
              end_on: preauthorize_form.end_on
            }
          },
          gateway_fields: braintree_form.to_hash
        })

      unless transaction_response[:success]
        flash[:error] = "An error occured while trying to create a new transaction: #{transaction_response[:error_msg]}"
        return redirect_to action: :book, start_on: stringify_booking_date(start_on), end_on: stringify_booking_date(end_on)
      end

      transaction_id = transaction_response[:data][:transaction][:id]

      MarketplaceService::Transaction::Command.transition_to(transaction_id, "preauthorized")
      redirect_to person_transaction_path(:person_id => @current_user.id, :id => transaction_id)
    else
      flash[:error] = preauthorize_form.errors.full_messages.join(", ")
      return redirect_to action: :book, start_on: stringify_booking_date(start_on), end_on: stringify_booking_date(end_on)
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

  def parse_booking_date(str)
    Date.parse(str)
  end

  def stringify_booking_date(date)
    date.iso8601
  end

  def verified_booking_data(start_on, end_on)
    booking_form = BookingForm.new({
      start_on: parse_booking_date(start_on),
      end_on: parse_booking_date(end_on)
    })

    if !booking_form.valid?
      { error: booking_data[:form].errors.full_messages }
    else
      booking_form.to_hash.merge({
        duration: DateUtils.duration_days(booking_form.start_on, booking_form.end_on)
      })
    end
  end
end
