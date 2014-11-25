class PreauthorizeTransactionsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply
  before_filter :ensure_can_receive_payment

  skip_filter :dashboard_only

  BookingForm = FormUtils.define_form("BookingForm", :start_on, :end_on)
    .with_validations do
      validates :start_on, :end_on, presence: true
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
    vprms = view_params(params[:listing_id])

    render "listing_conversations/initiate", locals: {
      preauthorize_form: PreauthorizeMessageForm.new,
      listing: vprms[:listing],
      sum: vprms[:listing][:price],
      author: PersonQuery.person(vprms[:listing][:author_id], @current_community.id),
      action_button_label: vprms[:action_button_label],
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(vprms[:payment_type]),
      form_action: initiated_order_path(person_id: @current_user.id, listing_id: vprms[:listing][:id])
    }
  end

  def initiated
    conversation_params = params[:listing_conversation]

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      return render_error_response(request.xhr?, t("error_messages.transaction_agreement.required_error"), action: :initiate)
    end

    preauthorize_form = PreauthorizeMessageForm.new(conversation_params.merge({
      listing_id: @listing.id
    }))
    unless preauthorize_form.valid?
      return render_error_response(request.xhr?, preauthorize_form.errors.full_messages.join(", "), action: :initiate)
    end

    transaction_response = create_preauth_transaction(
      payment_type: :paypal,
      community: @current_community,
      listing: @listing,
      user: @current_user,
      content: preauthorize_form.content,
      use_async: request.xhr?)

    unless transaction_response[:success]
      return render_error_response(request.xhr?, t("error_messages.paypal.generic_error"), action: :initiate) unless transaction_response[:success]
    end

    transaction_id = transaction_response[:data][:transaction][:id]
    MarketplaceService::Transaction::Command.transition_to(transaction_id, "initiated")

    if (transaction_response[:data][:gateway_fields][:redirect_url])
      redirect_to transaction_response[:data][:gateway_fields][:redirect_url]
    else
      render json: {
        op_status_url: transaction_op_status_path(transaction_response[:data][:gateway_fields][:process_token]),
        op_error_msg: t("error_messages.paypal.generic_error")
      }
    end
  end

  def book
    vprms = view_params(params[:listing_id])
    booking_data = verified_booking_data(params[:start_on], params[:end_on])

    if booking_data[:error].present?
      flash[:error] = booking_data[:error]
      return redirect_to listing_path(vprms[:listing][:id])
    end

    gateway_locals =
      if (vprms[:payment_type] == :braintree)
        braintree_gateway_locals(@current_community.id)
      else
        {}
      end

    view =
      case vprms[:payment_type]
      when :braintree
        "listing_conversations/preauthorize"
      when :paypal
        "listing_conversations/initiate"
      else
        raise ArgumentError.new("Unknown payment type #{vprms[:payment_type]} for booking")
      end

    render view, locals: {
      preauthorize_form: PreauthorizeBookingForm.new({
          start_on: booking_data[:start_on],
          end_on: booking_data[:end_on]
        }),
      listing: vprms[:listing],
      sum: vprms[:listing][:price] * booking_data[:duration],
      duration: booking_data[:duration],
      author: PersonQuery.person(vprms[:listing][:author_id], @current_community.id),
      action_button_label: vprms[:action_button_label],
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(vprms[:payment_type]),
      form_action: booked_path(person_id: @current_user.id, listing_id: vprms[:listing][:id])
    }.merge(gateway_locals)
  end

  def booked
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)
    conversation_params = params[:listing_conversation]

    start_on = DateUtils.from_date_select(conversation_params, :start_on)
    end_on = DateUtils.from_date_select(conversation_params, :end_on)
    preauthorize_form = PreauthorizeBookingForm.new(conversation_params.merge({
      start_on: start_on,
      end_on: end_on,
      listing_id: @listing.id
    }))

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      return render_error_response(request.xhr?,
        t("error_messages.transaction_agreement.required_error"),
        { Action: :book, start_on: stringify_booking_date(start_on), end_on: stringify_booking_date(end_on) })
    end

    unless preauthorize_form.valid?
      return render_error_response(request.xhr?,
        preauthorize_form.errors.full_messages.join(", "),
       { action: :book, start_on: stringify_booking_date(start_on), end_on: stringify_booking_date(end_on) })
    end

    transaction_response = create_preauth_transaction(
      payment_type: payment_type,
      community: @current_community,
      listing: @listing,
      user: @current_user,
      listing_quantity: DateUtils.duration_days(preauthorize_form.start_on, preauthorize_form.end_on),
      content: preauthorize_form.content,
      use_async: request.xhr?,
      bt_payment_params: params[:braintree_payment],
      booking_fields: {
        start_on: preauthorize_form.start_on,
        end_on: preauthorize_form.end_on
      })

    unless transaction_response[:success]
      error =
        if (payment_type == :paypal)
          t("error_messages.paypal.generic_error")
        else
          "An error occured while trying to create a new transaction: #{transaction_response[:error_msg]}"
        end

      return render_error_response(request.xhr?, error, { action: :book, start_on: stringify_booking_date(start_on), end_on: stringify_booking_date(end_on) })
    end

    transaction_id = transaction_response[:data][:transaction][:id]

    case payment_type
    when :paypal
      MarketplaceService::Transaction::Command.transition_to(transaction_id, "initiated")
      if (transaction_response[:data][:gateway_fields][:redirect_url])
        return redirect_to transaction_response[:data][:gateway_fields][:redirect_url]
      else
        return render json: {
          op_status_url: transaction_op_status_path(transaction_response[:data][:gateway_fields][:process_token]),
          op_error_msg: t("error_messages.paypal.generic_error")
        }
      end
    when :braintree
      MarketplaceService::Transaction::Command.transition_to(transaction_id, "preauthorized")
      return redirect_to person_transaction_path(:person_id => @current_user.id, :id => transaction_id)
    end

  end

  def preauthorize
    vprms = view_params(params[:listing_id])
    braintree_settings = BraintreePaymentQuery.braintree_settings(@current_community.id)

    render "listing_conversations/preauthorize", locals: {
      preauthorize_form: PreauthorizeMessageForm.new,
      braintree_client_side_encryption_key: braintree_settings[:braintree_client_side_encryption_key],
      braintree_form: BraintreeForm.new,
      listing: vprms[:listing],
      sum: vprms[:listing][:price],
      author: PersonQuery.person(vprms[:listing][:author_id], @current_community.id),
      action_button_label: vprms[:action_button_label],
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(vprms[:payment_type]),
      form_action: preauthorized_payment_path(person_id: @current_user.id, listing_id: vprms[:listing][:id])
    }
  end

  def preauthorized
    conversation_params = params[:listing_conversation]

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      flash[:error] = t("error_messages.transaction_agreement.required_error")
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

  private


  def view_params(listing_id)
    listing = ListingQuery.listing_with_transaction_type(listing_id)
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)

    action_button_label = listing[:transaction_type][:action_button_label_translations]
      .select {|translation| translation[:locale] == I18n.locale}
      .first

    { listing: listing, payment_type: payment_type, action_button_label: action_button_label }
  end

  def render_error_response(isXhr, error_msg, redirect_params)
    if isXhr
      render json: { error_msg: error_msg }
    else
      flash[:error] = error_msg
      redirect_to(redirect_params)
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

  def new_contact_form(conversation_params = {})
    ContactForm.new(conversation_params.merge({sender_id: @current_user.id, listing_id: @listing.id, community_id: @current_community.id}))
  end

  def ensure_can_receive_payment
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id) || :none

    ready = TransactionService::Transaction.can_start_transaction(transaction: {
        payment_gateway: payment_type,
        community_id: @current_community.id,
        listing_author_id: @listing.author.id
      })

    unless ready[:data][:result]
      flash[:error] = t("layouts.notifications.listing_author_payment_details_missing")
      return redirect_to listing_path(@listing)
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
      { error: booking_form.errors.full_messages }
    else
      booking_form.to_hash.merge({
        duration: DateUtils.duration_days(booking_form.start_on, booking_form.end_on)
      })
    end
  end

  def braintree_gateway_locals(community_id)
    braintree_settings = BraintreePaymentQuery.braintree_settings(community_id)

    {
      braintree_client_side_encryption_key: braintree_settings[:braintree_client_side_encryption_key],
      braintree_form: BraintreeForm.new
    }
  end


  def create_preauth_transaction(opts)
    gateway_fields =
      if (opts[:payment_type] == :paypal)
        # PayPal doesn't like images with cache buster in the URL
        logo_url = Maybe(opts[:community])
          .wide_logo
          .select { |wl| wl.present? }
          .url(:paypal, timestamp: false)
          .or_else(nil)

        {
          merchant_brand_logo_url: logo_url,
          success_url: success_paypal_service_checkout_orders_url,
          cancel_url: cancel_paypal_service_checkout_orders_url(listing_id: opts[:listing].id)
        }
      else
        BraintreeForm.new(opts[:bt_payment_params]).to_hash
      end

    TransactionService::Transaction.create({
        transaction: {
          community_id: opts[:community].id,
          listing_id: opts[:listing].id,
          starter_id: opts[:user].id,
          listing_author_id: opts[:listing].author.id,
          listing_quantity: opts[:listing_quantity],
          content: opts[:content],
          payment_gateway: opts[:payment_type],
          payment_process: :preauthorize,
          commission_from_seller: opts[:community].commission_from_seller,
          booking_fields: opts[:booking_fields]
        },
        gateway_fields: gateway_fields
      },
      paypal_async: opts[:use_async])
  end

end
