# coding: utf-8
class PreauthorizeTransactionsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_do_a_transaction")
  end

  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply
  before_filter :ensure_can_receive_payment

  IS_POSITIVE = ->(v) {
    return if v.nil?
    unless v.positive?
      {code: :positive_integer, msg: "Value must be a positive integer"}
    end
  }

  PARSE_DATE = ->(v) {
    return if v.nil?
    begin
      TransactionViewUtils.parse_booking_date(v)
    rescue ArgumentError => e
      # The transformator has to return something else than `Date` or
      # `nil` so that the `date` validator know that it's not a valid
      # date
      e
    end
  }

  NewTransactionParams = EntityUtils.define_builder(
    [:delivery, :to_symbol, one_of: [nil, :shipping, :pickup]],
    [:start_on, :date, transform_with: PARSE_DATE],
    [:end_on, :date, transform_with: PARSE_DATE],
    [:message, :string],
    [:quantity, :to_integer, validate_with: IS_POSITIVE],
    [:contract_agreed, transform_with: ->(v) { v == "1" }]
  )

  ListingQuery = MarketplaceService::Listing::Query

  class ItemTotal
    attr_reader :unit_price, :quantity

    def initialize(unit_price:, quantity:)
      @unit_price = unit_price
      @quantity = quantity
    end

    def total
      unit_price * quantity
    end
  end

  class ShippingTotal
    attr_reader :initial, :additional, :quantity

    def initialize(initial:, additional:, quantity:)
      @initial = initial || 0
      @additional = additional || 0
      @quantity = quantity
    end

    def total
      initial + (additional * (quantity - 1))
    end
  end

  class NoShippingFee
    def total
      0
    end
  end

  class OrderTotal
    attr_reader :item_total, :shipping_total

    def initialize(item_total:, shipping_total:)
      @item_total = item_total
      @shipping_total = shipping_total
    end

    def total
      item_total.total + shipping_total.total
    end
  end

  module Validator

    module_function

    def validate_initiate_params(tx_params:,
                                 is_booking:,
                                 shipping_enabled:,
                                 pickup_enabled:)

      validate_delivery_method(tx_params: tx_params, shipping_enabled: shipping_enabled, pickup_enabled: pickup_enabled)
        .and_then { validate_booking(tx_params: tx_params, is_booking: is_booking) }
    end

    def validate_initiated_params(tx_params:,
                                  is_booking:,
                                  shipping_enabled:,
                                  pickup_enabled:,
                                  transaction_agreement_in_use:)

      validate_delivery_method(tx_params: tx_params, shipping_enabled: shipping_enabled, pickup_enabled: pickup_enabled)
        .and_then { validate_booking(tx_params: tx_params, is_booking: is_booking) }
        .and_then {
          validate_transaction_agreement(tx_params: tx_params,
                                         transaction_agreement_in_use: transaction_agreement_in_use)
        }
    end

    def validate_delivery_method(tx_params:, shipping_enabled:, pickup_enabled:)
      delivery = tx_params[:delivery]

      case [delivery, shipping_enabled, pickup_enabled]
      when matches([:shipping, true])
        Result::Success.new(tx_params.merge(delivery: :shipping))
      when matches([:pickup, __, true])
        Result::Success.new(tx_params.merge(delivery: :pickup))
      when matches([nil, false, false])
        Result::Success.new(tx_params.merge(delivery: :nil))
      else
        Result::Error.new(nil, code: :delivery_method_missing, tx_params: tx_params)
      end
    end

    def validate_booking(tx_params:, is_booking:)
      if is_booking
        start_on, end_on = tx_params.values_at(:start_on, :end_on)

        if start_on.nil? || end_on.nil?
          Result::Error.new(nil, code: :dates_missing, tx_params: tx_params)
        elsif start_on > end_on
          Result::Error.new(nil, code: :end_cant_be_before_start, tx_params: tx_params)
        else
          Result::Success.new(tx_params)
        end
      else
        Result::Success.new(tx_params)
      end
    end

    def validate_transaction_agreement(tx_params:, transaction_agreement_in_use:)
      contract_agreed = tx_params[:contract_agreed]

      if transaction_agreement_in_use
        if contract_agreed
          Result::Success.new(tx_params)
        else
          Result::Error.new(nil, code: :agreement_missing, tx_params: tx_params)
        end
      else
        Result::Success.new(tx_params)
      end
    end
  end

  def initiate
    validation_result = NewTransactionParams.validate(params).and_then { |params_entity|
      tx_params = add_defaults(
        params: params_entity,
        shipping_enabled: listing.require_shipping_address,
        pickup_enabled: listing.pickup_enabled)

      Validator.validate_initiate_params(tx_params: tx_params,
                                         is_booking: booking?(listing),
                                         shipping_enabled: listing.require_shipping_address,
                                         pickup_enabled: listing.pickup_enabled)
    }

    validation_result.on_success { |tx_params|
      is_booking = booking?(listing)

      quantity = calculate_quantity(tx_params: tx_params, is_booking: is_booking)

      listing_entity = ListingQuery.listing(params[:listing_id])

      item_total = ItemTotal.new(
        unit_price: listing_entity[:price],
        quantity: quantity)

      shipping_total =
        if tx_params[:delivery] == :shipping
          ShippingTotal.new(
            initial: listing_entity[:shipping_price],
            additional: listing_entity[:shipping_price_additional],
            quantity: quantity)
        else
          NoShippingFee.new
        end

      order_total = OrderTotal.new(
        item_total: item_total,
        shipping_total: shipping_total)

      render "listing_conversations/initiate",
             locals: {
               start_on: tx_params[:start_on],
               end_on: tx_params[:end_on],
               listing: listing_entity,
               delivery_method: tx_params[:delivery],
               quantity: tx_params[:quantity],
               author: query_person_entity(listing_entity[:author_id]),
               action_button_label: translate(listing_entity[:action_button_tr_key]),
               expiration_period: MarketplaceService::Transaction::Entity.authorization_expiration_period(:paypal),
               form_action: initiated_order_path(person_id: @current_user.id, listing_id: listing_entity[:id]),
               country_code: LocalizationUtils.valid_country_code(@current_community.country),
               price_break_down_locals: TransactionViewUtils.price_break_down_locals(
                 booking:  is_booking,
                 quantity: quantity,
                 start_on: tx_params[:start_on],
                 end_on:   tx_params[:end_on],
                 duration: quantity,
                 listing_price: listing_entity[:price],
                 localized_unit_type: translate_unit_from_listing(listing_entity),
                 localized_selector_label: translate_selector_label_from_listing(listing_entity),
                 subtotal: subtotal_to_show(order_total),
                 shipping_price: shipping_price_to_show(tx_params[:delivery], shipping_total),
                 total: order_total.total)
             }

    }

    validation_result.on_error { |msg, data|
      error_msg =
        if data.is_a?(Array)
          # Entity validation failed
          t("listing_conversations.preauthorize.invalid_parameters")
        elsif [:dates_missing, :end_cant_be_before_start, :delivery_method_missing].include?(data[:code])
          t("listing_conversations.preauthorize.invalid_parameters")
        else
          raise NotImplementedError.new("No error handler for: #{msg}, #{data.inspect}")
        end

      flash[:error] = error_msg
      logger.error(msg, :transaction_initiate_error, data)
      redirect_to listing_path(listing.id)
    }
  end

  def initiated
    validation_result = NewTransactionParams.validate(params).and_then { |params_entity|
      tx_params = add_defaults(
        params: params_entity,
        shipping_enabled: listing.require_shipping_address,
        pickup_enabled: listing.pickup_enabled)

      is_booking = booking?(listing)

      Validator.validate_initiated_params(tx_params: tx_params,
                                          is_booking: is_booking,
                                          shipping_enabled: listing.require_shipping_address,
                                          pickup_enabled: listing.pickup_enabled,
                                          transaction_agreement_in_use: @current_community.transaction_agreement_in_use?)
    }

    validation_result.on_error { |msg, data|
      error_msg, path =
        case data[:code]
        when :dates_missing
          [t("listing_conversations.preauthorize.booking_dates_missing"), listing_path(listing.id)]
        when :end_cant_be_before_start
          [t("listing_conversations.preauthorize.end_cant_be_before_start"), listing_path(listing.id)]
        when :delivery_method_missing
          [t("listing_conversations.preauthorize.delivery_method_missing"), listing_path(listing.id)]
        when :agreement_missing
          [t("error_messages.transaction_agreement.required_error"), error_path(data[:tx_params])]
        else
          raise NotImplementedError.new("Unknown error #{data[:code]}")
        end
    }

    validation_result.on_success { |tx_params|
      is_booking = booking?(listing)

      quantity = calculate_quantity(tx_params: tx_params, is_booking: is_booking)

      shipping_total =
        if tx_params[:delivery] == :shipping
          ShippingTotal.new(
            initial: listing.shipping_price,
            additional: listing.shipping_price_additional,
            quantity: quantity)
        else
          NoShippingFee.new
        end

      tx_response = create_preauth_transaction(
        payment_type: :paypal,
        community: @current_community,
        listing: listing,
        listing_quantity: quantity,
        user: @current_user,
        content: tx_params[:message],
        use_async: request.xhr?,
        delivery_method: tx_params[:delivery],
        shipping_price: shipping_total.total,
        booking_fields: {
          start_on: tx_params[:start_on],
          end_on: tx_params[:end_on]
        })

      handle_tx_response(tx_response)
    }

    validation_result.on_error { |msg, data|
      error_msg, path =
        if data.is_a?(Array)
          # Entity validation failed
          logger.error(msg, :transaction_initiated_error, data)
          [t("listing_conversations.preauthorize.invalid_parameters"), listing_path(listing.id)]

        elsif [:dates_missing, :end_cant_be_before_start, :delivery_method_missing].include?(data[:code])
          logger.error(msg, :transaction_initiated_error, data)
          [t("listing_conversations.preauthorize.invalid_parameters"), listing_path(listing.id)]
        elsif data[:code] == :agreement_missing
          # User error, no logging here
          [t("error_messages.transaction_agreement.required_error"), error_path(data[:tx_params])]
        else
          raise NotImplementedError.new("No error handler for: #{msg}, #{data.inspect}")
        end

      render_error_response(request.xhr?, error_msg, path)
    }
  end

  private

  def add_defaults(params:, shipping_enabled:, pickup_enabled:)
    default_shipping =
      case [shipping_enabled, pickup_enabled]
      when [true, false]
        {delivery: :shipping}
      when [false, true]
        {delivery: :pickup}
      when [false, false]
        {delivery: nil}
      else
        {}
      end

    params.merge(default_shipping)
  end

  def handle_tx_response(tx_response)
    if !tx_response[:success]
      render_error_response(request.xhr?, t("error_messages.paypal.generic_error"), action: :initiate)
    elsif (tx_response[:data][:gateway_fields][:redirect_url])
      if request.xhr?
        render json: {
                 redirect_url: tx_response[:data][:gateway_fields][:redirect_url]
               }
      else
        redirect_to tx_response[:data][:gateway_fields][:redirect_url]
      end
    else
      render json: {
               op_status_url: transaction_op_status_path(tx_response[:data][:gateway_fields][:process_token]),
               op_error_msg: t("error_messages.paypal.generic_error")
             }
    end
  end

  def calculate_quantity(tx_params:, is_booking:)
    if is_booking
      DateUtils.duration_days(tx_params[:start_on], tx_params[:end_on])
    else
      tx_params[:quantity] || 1
    end
  end

  def error_path(tx_params)
    booking_dates = HashUtils.map_values(tx_params.slice(:start_on, :end_on).compact) { |date|
      TransactionViewUtils.stringify_booking_date(date)
    }

    {action: :initiate}.merge(booking_dates)
  end

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

  def subtotal_to_show(order_total)
    order_total.item_total.total if show_subtotal?(order_total)
  end

  def shipping_price_to_show(delivery_method, shipping_total)
    shipping_total.total if show_shipping_price?(delivery_method)
  end

  def show_subtotal?(order_total)
    order_total.total != order_total.item_total.unit_price
  end

  def show_shipping_price?(delivery_method)
    delivery_method == :shipping
  end

  def booking?(listing)
    [:day].include?(listing.unit_type&.to_sym)
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
    if listing.author == @current_user
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to(session[:return_to_content] || search_path)
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    unless listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to search_path
    end
  end

  def ensure_listing_is_open
    if listing.closed?
      flash[:error] = t("layouts.notifications.you_cannot_reply_to_a_closed_offer")
      redirect_to(session[:return_to_content] || search_path)
    end
  end

  def listing
    @listing ||= Listing.find_by(
      id: params[:listing_id], community_id: @current_community.id) or render_not_found!("Listing #{params[:listing_id]} not found from community #{@current_community.id}")
  end

  def ensure_can_receive_payment
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id) || :none

    ready = TransactionService::Transaction.can_start_transaction(transaction: {
        payment_gateway: payment_type,
        community_id: @current_community.id,
        listing_author_id: listing.author.id
      })

    unless ready[:data][:result]
      flash[:error] = t("layouts.notifications.listing_author_payment_details_missing")
      redirect_to listing_path(listing)
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
end
