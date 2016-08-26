class PreauthorizeTransactionsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_do_a_transaction")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply
  before_filter :ensure_can_receive_payment

  BookingForm = FormUtils.define_form("BookingForm", :start_on, :end_on)
    .with_validations do
      validates :start_on, :end_on, presence: true
      validates_with DateValidator,
                     attribute: :end_on,
                     compare_to: :start_on,
                     restriction: :on_or_after
    end

  ContactForm = FormUtils.define_form("ListingConversation", :content, :sender_id, :listing_id, :community_id)
    .with_validations { validates_presence_of :content, :listing_id }

  PreauthorizeMessageForm = FormUtils.define_form("ListingConversation",
    :content,
    :sender_id,
    :contract_agreed,
    :delivery_method,
    :quantity,
    :listing_id
   ).with_validations {
    validates_presence_of :listing_id
    validates :delivery_method, inclusion: { in: %w(shipping pickup), message: "%{value} is not shipping or pickup." }, allow_nil: true
  }

  PreauthorizeBookingForm = FormUtils.merge("ListingConversation", PreauthorizeMessageForm, BookingForm)

  ListingQuery = MarketplaceService::Listing::Query

  def initiate
    delivery_method = valid_delivery_method(delivery_method_str: params[:delivery],
                                            shipping: @listing.require_shipping_address,
                                            pickup: @listing.pickup_enabled)
    if(delivery_method == :errored)
      return redirect_to error_not_found_path
    end

    quantity = TransactionViewUtils.parse_quantity(params[:quantity])

    vprms = view_params(listing_id: params[:listing_id],
                        quantity: quantity,
                        shipping_enabled: delivery_method == :shipping)

    price_break_down_locals = TransactionViewUtils.price_break_down_locals({
      booking:  false,
      quantity: quantity,
      listing_price: vprms[:listing][:price],
      localized_unit_type: translate_unit_from_listing(vprms[:listing]),
      localized_selector_label: translate_selector_label_from_listing(vprms[:listing]),
      subtotal: (quantity > 1 || vprms[:listing][:shipping_price].present?) ? vprms[:subtotal] : nil,
      shipping_price: delivery_method == :shipping ? vprms[:shipping_price] : nil,
      total: vprms[:total_price]
    })

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    render "listing_conversations/initiate", locals: {
      preauthorize_form: PreauthorizeMessageForm.new,
      listing: vprms[:listing],
      delivery_method: delivery_method,
      quantity: quantity,
      author: query_person_entity(vprms[:listing][:author_id]),
      action_button_label: vprms[:action_button_label],
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(vprms[:payment_type]),
      form_action: initiated_order_path(person_id: @current_user.id, listing_id: vprms[:listing][:id]),
      price_break_down_locals: price_break_down_locals,
      country_code: community_country_code
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
    delivery_method = valid_delivery_method(delivery_method_str: preauthorize_form.delivery_method,
                                            shipping: @listing.require_shipping_address,
                                            pickup: @listing.pickup_enabled)
    if(delivery_method == :errored)
      return render_error_response(request.xhr?, "Delivery method is invalid.", action: :initiate)
    end

    quantity = TransactionViewUtils.parse_quantity(preauthorize_form.quantity)
    shipping_price = shipping_price_total(@listing.shipping_price, @listing.shipping_price_additional, quantity)

    transaction_response = create_preauth_transaction(
      payment_type: :paypal,
      community: @current_community,
      listing: @listing,
      listing_quantity: quantity,
      user: @current_user,
      content: preauthorize_form.content,
      use_async: request.xhr?,
      delivery_method: delivery_method,
      shipping_price: shipping_price
    )

    unless transaction_response[:success]
      return render_error_response(request.xhr?, t("error_messages.paypal.generic_error"), action: :initiate) unless transaction_response[:success]
    end

    if (transaction_response[:data][:gateway_fields][:redirect_url])
      if request.xhr?
        render json: {
          redirect_url: transaction_response[:data][:gateway_fields][:redirect_url]
        }
      else
        redirect_to transaction_response[:data][:gateway_fields][:redirect_url]
      end
    else
      render json: {
        op_status_url: transaction_op_status_path(transaction_response[:data][:gateway_fields][:process_token]),
        op_error_msg: t("error_messages.paypal.generic_error")
      }
    end
  end

  def book
    delivery_method = valid_delivery_method(delivery_method_str: params[:delivery],
                                            shipping: @listing.require_shipping_address,
                                            pickup: @listing.pickup_enabled)
    if(delivery_method == :errored)
      return redirect_to error_not_found_path
    end

    booking_data = verified_booking_data(params[:start_on], params[:end_on])
    vprms = view_params(listing_id: params[:listing_id],
                        quantity: booking_data[:duration],
                        shipping_enabled: delivery_method == :shipping)

    if booking_data[:error].present?
      flash[:error] = booking_data[:error]
      return redirect_to listing_path(vprms[:listing][:id])
    end

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    price_break_down_locals = TransactionViewUtils.price_break_down_locals({
      booking:  true,
      start_on: booking_data[:start_on],
      end_on:   booking_data[:end_on],
      duration: booking_data[:duration],
      listing_price: vprms[:listing][:price],
      localized_unit_type: translate_unit_from_listing(vprms[:listing]),
      localized_selector_label: translate_selector_label_from_listing(vprms[:listing]),
      subtotal: vprms[:subtotal],
      shipping_price: delivery_method == :shipping ? vprms[:shipping_price] : nil,
      total: vprms[:total_price]
    })

    render "listing_conversations/initiate", locals: {
      preauthorize_form: PreauthorizeBookingForm.new({
          start_on: booking_data[:start_on],
          end_on: booking_data[:end_on]
      }),
      country_code: community_country_code,
      listing: vprms[:listing],
      delivery_method: delivery_method,
      subtotal: vprms[:subtotal],
      author: query_person_entity(vprms[:listing][:author_id]),
      action_button_label: vprms[:action_button_label],
      expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(vprms[:payment_type]),
      form_action: booked_path(person_id: @current_user.id, listing_id: vprms[:listing][:id]),
      price_break_down_locals: price_break_down_locals
    }
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
        { action: :book, start_on: TransactionViewUtils.stringify_booking_date(start_on), end_on: TransactionViewUtils.stringify_booking_date(end_on) })
    end

    delivery_method = valid_delivery_method(delivery_method_str: preauthorize_form.delivery_method,
                                            shipping: @listing.require_shipping_address,
                                            pickup: @listing.pickup_enabled)
    if(delivery_method == :errored)
      return render_error_response(request.xhr?, "Delivery method is invalid.", action: :booked)
    end

    unless preauthorize_form.valid?
      return render_error_response(request.xhr?,
        preauthorize_form.errors.full_messages.join(", "),
       { action: :book, start_on: TransactionViewUtils.stringify_booking_date(start_on), end_on: TransactionViewUtils.stringify_booking_date(end_on) })
    end

    transaction_response = create_preauth_transaction(
      payment_type: payment_type,
      community: @current_community,
      listing: @listing,
      user: @current_user,
      listing_quantity: DateUtils.duration_days(preauthorize_form.start_on, preauthorize_form.end_on),
      content: preauthorize_form.content,
      use_async: request.xhr?,
      delivery_method: delivery_method,
      shipping_price: @listing.shipping_price,
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

      return render_error_response(request.xhr?, error, { action: :book, start_on: TransactionViewUtils.stringify_booking_date(start_on), end_on: TransactionViewUtils.stringify_booking_date(end_on) })
    end

    if (transaction_response[:data][:gateway_fields][:redirect_url])
      if request.xhr?
        render json: {
          redirect_url: transaction_response[:data][:gateway_fields][:redirect_url]
        }
      else
        redirect_to transaction_response[:data][:gateway_fields][:redirect_url]
      end
    else
      render json: {
        op_status_url: transaction_op_status_path(transaction_response[:data][:gateway_fields][:process_token]),
        op_error_msg: t("error_messages.paypal.generic_error")
      }
    end
  end

  private

  def translate_unit_from_listing(listing)
    Maybe(listing).select { |l|
      l[:unit_type].present?
    }.map { |l|
      ListingViewUtils.translate_unit(l[:unit_type], l[:unit_tr_key])
    }.or_else(nil)
  end

  def translate_selector_label_from_listing(listing)
    Maybe(listing).select { |l|
      l[:unit_type].present?
    }.map { |l|
      ListingViewUtils.translate_quantity(l[:unit_type], l[:unit_selector_tr_key])
    }.or_else(nil)
  end

  def view_params(listing_id:, quantity: 1, shipping_enabled: false)
    listing = ListingQuery.listing(listing_id)
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)

    action_button_label = translate(listing[:action_button_tr_key])

    subtotal = listing[:price] * quantity
    shipping_price = shipping_price_total(listing[:shipping_price], listing[:shipping_price_additional], quantity)
    total_price = shipping_enabled ? subtotal + shipping_price : subtotal

    { listing: listing,
      payment_type: payment_type,
      action_button_label: action_button_label,
      subtotal: subtotal,
      shipping_price: shipping_price,
      total_price: total_price }
  end

  def render_error_response(is_xhr, error_msg, redirect_params)
    if is_xhr
      render json: { error_msg: error_msg }
    else
      flash[:error] = error_msg
      redirect_to(redirect_params)
    end
  end

  def ensure_listing_author_is_not_current_user
    if @listing.author == @current_user
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to(session[:return_to_content] || search_path)
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
      redirect_to(session[:return_to_content] || search_path)
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

  def verified_booking_data(start_on, end_on)
    booking_form = BookingForm.new({
      start_on: TransactionViewUtils.parse_booking_date(start_on),
      end_on: TransactionViewUtils.parse_booking_date(end_on)
    })

    if !booking_form.valid?
      { error: booking_form.errors.full_messages }
    else
      booking_form.to_hash.merge({
        duration: DateUtils.duration_days(booking_form.start_on, booking_form.end_on)
      })
    end
  end

  def valid_delivery_method(delivery_method_str:, shipping:, pickup:)
    case [delivery_method_str, shipping, pickup]
    when matches([nil, true, false]), matches(["shipping", true, __])
      :shipping
    when matches([nil, false, true]), matches(["pickup", __, true])
      :pickup
    when matches([nil, false, false])
      nil
    else
      :errored
    end
  end

  def create_preauth_transaction(opts)
    # PayPal doesn't like images with cache buster in the URL
    logo_url = Maybe(opts[:community])
                 .wide_logo
                 .select { |wl| wl.present? }
                 .url(:paypal, timestamp: false)
                 .or_else(nil)

    gateway_fields =
      {
        merchant_brand_logo_url: logo_url,
        success_url: success_paypal_service_checkout_orders_url,
        cancel_url: cancel_paypal_service_checkout_orders_url(listing_id: opts[:listing].id)
      }

    transaction = {
          community_id: opts[:community].id,
          listing_id: opts[:listing].id,
          listing_title: opts[:listing].title,
          starter_id: opts[:user].id,
          listing_author_id: opts[:listing].author.id,
          listing_quantity: opts[:listing_quantity],
          unit_type: opts[:listing].unit_type,
          unit_price: opts[:listing].price,
          unit_tr_key: opts[:listing].unit_tr_key,
          unit_selector_tr_key: opts[:listing].unit_selector_tr_key,
          content: opts[:content],
          payment_gateway: opts[:payment_type],
          payment_process: :preauthorize,
          booking_fields: opts[:booking_fields],
          delivery_method: opts[:delivery_method]
    }

    if(opts[:delivery_method] == :shipping)
      transaction[:shipping_price] = opts[:shipping_price]
    end

    TransactionService::Transaction.create({
        transaction: transaction,
        gateway_fields: gateway_fields
      },
      paypal_async: opts[:use_async])
  end

  def query_person_entity(id)
    person_entity = MarketplaceService::Person::Query.person(id, @current_community.id)
    person_display_entity = person_entity.merge(
      display_name: PersonViewUtils.person_entity_display_name(person_entity, @current_community.name_display_type)
    )
  end

  def shipping_price_total(shipping_price, shipping_price_additional, quantity)
    Maybe(shipping_price)
      .map { |price|
        if shipping_price_additional.present? && quantity.present? && quantity > 1
          price + (shipping_price_additional * (quantity - 1))
        else
          price
        end
      }
      .or_else(nil)
  end

end
