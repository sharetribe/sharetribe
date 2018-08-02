class ListingPresenter < MemoisticPresenter
  include ListingAvailabilityManage
  attr_accessor :listing, :current_community, :form_path, :params, :current_image, :prev_image_id, :next_image_id
  attr_reader :shape

  def initialize(listing, current_community, params, current_user)
    @listing = listing
    @current_community = current_community
    @current_user = current_user
    @params = params
    set_current_image
  end

  def listing_shape=(listing_shape)
    @shape = listing_shape
  end

  def is_author
    @current_user == @listing.author
  end

  def is_marketplace_admin
    Maybe(@current_user).has_admin_rights?(@current_community).or_else(false)
  end

  def is_authorized
    is_authorized = is_author || is_marketplace_admin
  end

  def show_manage_availability
    is_authorized && availability_enabled
  end

  def paypal_in_use
    PaypalHelper.user_and_community_ready_for_payments?(@listing.author_id, @current_community.id)
  end

  def stripe_in_use
    StripeHelper.user_and_community_ready_for_payments?(@listing.author_id, @current_community.id)
  end

  def set_current_image
    @current_image = if params[:image]
      @listing.image_by_id(params[:image])
    else
      @listing.listing_images.first
    end

    @prev_image_id, @next_image_id = if @current_image
      @listing.prev_and_next_image_ids_by_id(@current_image.id)
    else
      [nil, nil]
    end
  end

  def received_testimonials
    TestimonialViewUtils.received_testimonials_in_community(@listing.author, @current_community)
  end

  def received_positive_testimonials
    TestimonialViewUtils.received_positive_testimonials_in_community(@listing.author, @current_community)
  end

  def feedback_positive_percentage
    @listing.author.feedback_positive_percentage_in_community(@current_community)
  end

  def youtube_link_ids
    ListingViewUtils.youtube_video_ids(@listing.description)
  end

  def currency
    Maybe(@listing.price).currency.or_else(Money::Currency.new(@current_community.currency))
  end

  def community_country_code
    LocalizationUtils.valid_country_code(@current_community.country)
  end

  def process
    return nil unless @listing.transaction_process_id
    get_transaction_process(community_id: @current_community.id, transaction_process_id: @listing.transaction_process_id)
  end

  def delivery_opts
    delivery_config(@listing.require_shipping_address, @listing.pickup_enabled, @listing.shipping_price, @listing.shipping_price_additional, @listing.currency)
  end

  def listing_unit_type
    @listing.unit_type
  end

  def manage_availability_props
    ManageAvailabilityHelper.availability_props(community: @current_community, listing: @listing)
  end

  def currency_opts
    MoneyViewUtils.currency_opts(I18n.locale, currency)
  end

  def delivery_config(require_shipping_address, pickup_enabled, shipping_price, shipping_price_additional, currency)
    shipping = delivery_price_hash(:shipping, shipping_price, shipping_price_additional) if require_shipping_address
    pickup = delivery_price_hash(:pickup, Money.new(0, currency), Money.new(0, currency))

    case [require_shipping_address, pickup_enabled]
    when matches([true, true])
      [shipping, pickup]
    when matches([true, false])
      [shipping]
    when matches([false, true])
      [pickup]
    else
      []
    end
  end

  def get_transaction_process(community_id:, transaction_process_id:)
    opts = {
      process_id: transaction_process_id,
      community_id: community_id
    }

    TransactionService::API::Api.processes.get(opts)
      .maybe
      .process
      .or_else(nil)
      .tap { |process|
        raise ArgumentError.new("Cannot find transaction process: #{opts}") if process.nil?
      }
  end

  def delivery_type
    delivery_opts.present? ? delivery_opts.first[:name].to_s : ""
  end

  def shipping_price_additional
    delivery_opts.present? ? delivery_opts.first[:shipping_price_additional] : nil
  end

  def delivery_price_hash(delivery_type, price, shipping_price_additional)
    { name: delivery_type,
      price: price,
      shipping_price_additional: shipping_price_additional,
      price_info: ListingViewUtils.shipping_info(delivery_type, price, shipping_price_additional),
      default: true
    }
  end

  def category_tree
    CategoryViewUtils.category_tree(
      categories: @current_community.categories,
      shapes: @current_community.shapes,
      locale: I18n.locale,
      all_locales: @current_community.locales
    )
  end

  def shapes
    ListingShape.where(community_id: @current_community.id).exist_ordered.all
  end

  def categories
    @current_community.top_level_categories
  end

  def subcategories
    @current_community.subcategories
  end

  def commission
    paypal_ready = PaypalHelper.community_ready_for_payments?(@current_community.id)
    stripe_ready = StripeHelper.community_ready_for_payments?(@current_community.id)

    supported = []
    supported << :paypal if paypal_ready
    supported << :stripe if stripe_ready
    payment_type = supported.size > 1 ? supported : supported.first

    currency = @current_community.currency
    process_id = shape ? shape[:transaction_process_id] : @listing.transaction_process_id
    process = get_transaction_process(community_id: @current_community.id, transaction_process_id: process_id)

    case [payment_type, process]
    when matches([__, :none])
      {
        commission_from_seller: 0,
        minimum_commission: Money.new(0, currency),
        minimum_price_cents: 0,
        payment_gateway: nil,
        paypal_commission: 0,
        paypal_minimum_transaction_fee: 0,
        seller_commission_in_use: false,
        stripe_commission: 0,
        stripe_minimum_transaction_fee: 0,
      }
    when matches([:paypal]), matches([:stripe]), matches([ [:paypal, :stripe] ])
      p_set = Maybe(payment_settings_api.get_active_by_gateway(community_id: @current_community.id, payment_gateway: payment_type))
        .select {|res| res[:success]}
        .map {|res| res[:data]}
        .or_else({})

      stripe_settings = Maybe(payment_settings_api.get_active_by_gateway(community_id: @current_community.id, payment_gateway: :stripe))
        .select {|res| res[:success]}
        .map {|res| res[:data]}
        .or_else({})

      paypal_settings = Maybe(payment_settings_api.get_active_by_gateway(community_id: @current_community.id, payment_gateway: :paypal))
        .select {|res| res[:success]}
        .map {|res| res[:data]}
        .or_else({})

      {
        commission_from_seller: p_set[:commission_from_seller],
        minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
        minimum_price_cents: p_set[:minimum_price_cents],
        payment_gateway: payment_type,
        paypal_commission: paypal_settings[:commission_from_seller],
        paypal_minimum_transaction_fee: Money.new(paypal_settings[:minimum_transaction_fee_cents], currency),
        seller_commission_in_use: p_set[:commission_type] != :none,
        stripe_commission: stripe_settings[:commission_from_seller],
        stripe_minimum_transaction_fee: Money.new(stripe_settings[:minimum_transaction_fee_cents], currency),
      }
    else
      raise ArgumentError.new("Unknown payment_type, process combination: [#{payment_type}, #{process}]")
    end
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  def unit_options
    unit_options = ListingViewUtils.unit_options(shape.units, unit_from_listing(@listing))
  end

  def unit_from_listing(listing)
    HashUtils.compact({
      unit_type: listing.unit_type.present? ? listing.unit_type.to_s : nil,
      quantity_selector: listing.quantity_selector,
      unit_tr_key: listing.unit_tr_key,
      unit_selector_tr_key: listing.unit_selector_tr_key
    })
  end

  def paypal_fees_url
    PaypalCountryHelper.fee_link(community_country_code)
  end

  def stripe_fees_url
    "https://stripe.com/#{community_country_code.downcase}/pricing"
  end

  def shipping_price
    @listing.shipping_price || "0"
  end

  def shipping_enabled
    @listing.require_shipping_address?
  end

  def pickup_enabled
    @listing.pickup_enabled?
  end

  def shipping_price_additional_in_form
    if @listing.shipping_price_additional
      @listing.shipping_price_additional.to_s
    elsif @listing.shipping_price
      @listing.shipping_price.to_s
    else
      0
    end
  end

  def always_show_additional_shipping_price
    shape && shape.units.length == 1 && shape.units.first[:kind] == 'quantity'
  end

  def category_id
    @listing.category.parent_id || @listing.category.id
  end

  def subcategory_id
    @listing.category.parent_id ?  @listing.category.id : nil
  end

  def payments_enabled?
    process == :preauthorize
  end

  memoize_all_reader_methods
end
