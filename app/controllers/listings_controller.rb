class ListingsController < ApplicationController
  class ListingDeleted < StandardError; end

  include PeopleHelper

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:close, :update, :follow, :unfollow]

  before_filter :only => [ :edit, :update, :close, :follow, :unfollow ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_create_new_listing", :sign_up_link => view_context.link_to(t("layouts.notifications.create_one_here"), sign_up_path)).html_safe
  end

  before_filter :save_current_path, :only => :show
  before_filter :ensure_authorized_to_view, :only => [ :show, :follow, :unfollow ]

  before_filter :only => [ :close ] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_close_a_listing")
  end

  before_filter :only => [ :edit, :update ] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_edit_a_listing")
  end

  before_filter :ensure_is_admin, :only => [ :move_to_top, :show_in_updates_email ]

  before_filter :is_authorized_to_post, :only => [ :new, :create ]

  def index
    @selected_tribe_navi_tab = "home"

    respond_to do |format|
      # Keep format.html at top, as order is important for HTTP_ACCEPT headers with '*/*'
      format.html do
        if request.xhr? && params[:person_id] # AJAX request to load on person's listings for profile view
          @person = Person.find(params[:person_id])
          PersonViewUtils.ensure_person_belongs_to_community!(@person, @current_community)

          # Returns the listings for one person formatted for profile page view
          per_page = params[:per_page] || 200 # the point is to show all here by default
          render :partial => "listings/profile_listings", :locals => {:person => @person, :limit => per_page}
        else
          redirect_to root
        end
      end

      format.atom do
        page =  params[:page] || 1
        per_page = params[:per_page] || 50

        listings = @current_community.private ? [] : Listing.find_with(params, @current_user, @current_community, per_page, page)
        title = build_title(params)
        updated = listings.first.present? ? listings.first.updated_at : Time.now

        render layout: false,
               locals: { listings: listings,
                         title: title,
                         updated: updated,

                         # deprecated
                         direction_map: ListingShapeHelper.transaction_types_to_direction_map(@current_community)
                       }
      end
    end
  end

  def listing_bubble
    if params[:id]
      @listing = Listing.find(params[:id])
      if @listing.visible_to?(@current_user, @current_community)
        render :partial => "homepage/listing_bubble", :locals => { :listing => @listing }
      else
        render :partial => "bubble_listing_not_visible"
      end
    end
  end

  # "2,3,4, 563" => [2, 3, 4, 563]
  def numbers_str_to_array(str)
    str.split(",").map { |num| num.to_i }
  end

  # Used to show multiple listings in one bubble
  def listing_bubble_multiple
    ids = numbers_str_to_array(params[:ids])
    @listings = Listing.visible_to(@current_user, @current_community, ids).order("id DESC")
    if @listings.size > 0
      render :partial => "homepage/listing_bubble_multiple"
    else
      render :partial => "bubble_listing_not_visible"
    end
  end

  def show
    @selected_tribe_navi_tab = "home"
    unless current_user?(@listing.author)
      @listing.increment!(:times_viewed)
    end

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

    payment_gateway = MarketplaceService::Community::Query.payment_type(@current_community.id)

    # TODO Change this so that the path is always the same, but the controller
    # decides what to do. We don't want to make a API call to TransactionService
    # just to show a listing details
    process = get_transaction_process(community: @current_community, listing: @listing)

    form_path = select_new_transaction_path(
      listing_id: @listing.id.to_s,
      payment_gateway: payment_gateway,
      payment_process: process,
      booking: @listing.transaction_type.price_per.present?
    )

    delivery_opts = delivery_config(@listing.require_shipping_address, @listing.pickup_enabled, @listing.shipping_price, @listing.currency)

    render locals: {
             form_path: form_path,
             payment_gateway: payment_gateway,
             process: process,
             delivery_opts: delivery_opts
           }
  end

  def new
    @selected_tribe_navi_tab = "new_listing"
    @listing = Listing.new

    if (@current_user.location != nil)
      temp = @current_user.location
      temp.location_type = "origin_loc"
      @listing.build_origin_loc(temp.attributes)
    else
      @listing.build_origin_loc(:location_type => "origin_loc")
    end

    if request.xhr? # AJAX request to get the actual form contents
      @listing.category = @current_community.categories.find(params[:subcategory].blank? ? params[:category] : params[:subcategory])
      @custom_field_questions = @listing.category.custom_fields
      @numeric_field_ids = numeric_field_ids(@custom_field_questions)

      @listing.transaction_type = @current_community.transaction_types.find(params[:transaction_type])
      logger.info "Category: #{@listing.category.inspect}"

      payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)
      allow_posting, error_msg = payment_setup_status(
                       community: @current_community,
                       user: @current_user,
                       listing: @listing,
                       payment_type: payment_type)

      if allow_posting
        render :partial => "listings/form/form_content", locals: commission(@current_community).merge(shipping_enabled: shipping_enabled?(@current_community))
      else
        render :partial => "listings/payout_registration_before_posting", locals: { error_msg: error_msg }
      end
    else
      render :new
    end
  end

  def create
    if params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin_loc_attributes][:address].blank?
      params[:listing].delete("origin_loc_attributes")
    end

    params[:listing] = normalize_price_param(params[:listing]);

    @listing = Listing.new(create_listing_params(params[:listing]))

    @listing.author = @current_user
    @listing.custom_field_values = create_field_values(params[:custom_fields])

    if @listing.save
      listing_image_ids = params[:listing_images].collect { |h| h[:id] }.select { |id| id.present? }
      ListingImage.where(id: listing_image_ids, author_id: @current_user.id).update_all(listing_id: @listing.id)

      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.id))
      if @current_community.follow_in_use?
        Delayed::Job.enqueue(NotifyFollowersJob.new(@listing.id, @current_community.id), :run_at => NotifyFollowersJob::DELAY.from_now)
      end

      flash[:notice] = t(
        "layouts.notifications.listing_created_successfully",
        :new_listing_link => view_context.link_to(t("layouts.notifications.create_new_listing"),new_listing_path)
        ).html_safe
      redirect_to @listing, status: 303 and return
    else
      Rails.logger.error "Errors in creating listing: #{@listing.errors.full_messages.inspect}"
      flash[:error] = t(
        "layouts.notifications.listing_could_not_be_saved",
        :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")
        ).html_safe
      redirect_to new_listing_path and return
    end
  end

  def edit
    @selected_tribe_navi_tab = "home"
    if !@listing.origin_loc
        @listing.build_origin_loc(:location_type => "origin_loc")
    end

    @custom_field_questions = @listing.category.custom_fields.find_all_by_community_id(@current_community.id)
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    render locals: commission(@current_community).merge(shipping_enabled: shipping_enabled?(@current_community))
  end

  def update
    if (params[:listing][:origin] && (params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin].blank?))
      params[:listing].delete("origin_loc_attributes")
      if @listing.origin_loc
        @listing.origin_loc.delete
      end
    end

    @listing.custom_field_values = create_field_values(params[:custom_fields])

    params[:listing] = normalize_price_param(params[:listing])

    if @listing.update_fields(create_listing_params(params[:listing]))
      @listing.location.update_attributes(params[:location]) if @listing.location
      flash[:notice] = t("layouts.notifications.listing_updated_successfully")
      Delayed::Job.enqueue(ListingUpdatedJob.new(@listing.id, @current_community.id))
      redirect_to @listing
    else
      Rails.logger.error "Errors in editing listing: #{@listing.errors.full_messages.inspect}"
      flash[:error] = t("layouts.notifications.listing_could_not_be_saved", :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")).html_safe
      redirect_to edit_listing_path(@listing)
    end
  end

  def close
    process = get_transaction_process(community: @current_community, listing: @listing)

    payment_gateway = MarketplaceService::Community::Query.payment_type(@current_community.id)

    @listing.update_attribute(:open, false)
    respond_to do |format|
      format.html {
        redirect_to @listing
      }
      format.js {
        render :layout => false, locals: {payment_gateway: payment_gateway, process: process}
      }
    end
  end

  def move_to_top
    @listing = @current_community.listings.find(params[:id])

    # Listings are sorted by `sort_date`, so change it to now.
    if @listing.update_attribute(:sort_date, Time.now)
      redirect_to homepage_index_path
    else
      flash[:warning] = "An error occured while trying to move the listing to the top of the homepage"
      Rails.logger.error "An error occured while trying to move the listing (id=#{Maybe(@listing).id.or_else('No id available')}) to the top of the homepage"
      redirect_to @listing
    end
  end

  def show_in_updates_email
    @listing = @current_community.listings.find(params[:id])

    # Listings are sorted by `created_at`, so change it to now.
    if @listing.update_attribute(:updates_email_at, Time.now)
      render :nothing => true, :status => 200
    else
      Rails.logger.error "An error occured while trying to move the listing (id=#{Maybe(@listing).id.or_else('No id available')}) to the top of the homepage"
      render :nothing => true, :status => 500
    end
  end

  #shows a random listing from current community
  def random
    open_listings_ids = Listing.currently_open.select("id").find_with(nil, @current_user, @current_community).all
    if open_listings_ids.empty?
      redirect_to root and return
      #render :action => :index and return
    end
    random_id = open_listings_ids[Kernel.rand(open_listings_ids.length)].id
    #redirect_to listing_path(random_id)
    @listing = Listing.find_by_id(random_id)
    render :action => :show
  end

  def ensure_current_user_is_listing_author(error_message)
    @listing = Listing.find(params[:id])
    return if current_user?(@listing.author) || @current_user.has_admin_rights_in?(@current_community)
    flash[:error] = error_message
    redirect_to @listing and return
  end

  def follow
    change_follow_status("follow")
  end

  def unfollow
    change_follow_status("unfollow")
  end

  def verification_required

  end

  private

  def build_title(params)
    category = Category.find_by_id(params["category"])
    category_label = (category.present? ? "(" + localized_category_label(category) + ")" : "")

    if ["request","offer"].include? params['share_type']
      listing_type_label = t("listings.index.#{params['share_type']+"s"}")
    else
      listing_type_label = t("listings.index.listings")
    end

    t("listings.index.feed_title",
      :optional_category => category_label,
      :community_name => @current_community.name_with_separator(I18n.locale),
      :listing_type => listing_type_label)
  end

  def commission(community)
    payment_type = MarketplaceService::Community::Query.payment_type(community.id)
    payment_settings = TransactionService::API::Api.settings.get_active(community_id: community.id).maybe
    currency = community.default_currency

    case payment_type
    when nil
      {seller_commission_in_use: false,
       payment_gateway: payment_type,
       minimum_commission: Money.new(0, currency),
       commission_from_seller: 0,
       minimum_price_cents: 0}
    when :paypal
      p_set = Maybe(payment_settings_api.get_active(community_id: community.id))
        .select {|res| res[:success]}
        .map {|res| res[:data]}
        .or_else({})

      {seller_commission_in_use: payment_settings[:commission_type].or_else(:none) != :none,
       payment_gateway: payment_type,
       minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
       commission_from_seller: p_set[:commission_from_seller],
       minimum_price_cents: p_set[:minimum_price_cents]}
    else
      {seller_commission_in_use: !!community.commission_from_seller,
       payment_gateway: payment_type,
       minimum_commission: Money.new(0, currency),
       commission_from_seller: community.commission_from_seller,
       minimum_price_cents: community.absolute_minimum_price(currency).cents}
    end
  end

  def shipping_enabled?(community)
    Maybe(community.marketplace_settings)
      .map { |settings| settings.shipping_enabled }
      .or_else(nil)
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions_api
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  # Ensure that only users with appropriate visibility settings can view the listing
  def ensure_authorized_to_view
    @listing = Listing.find(params[:id])

    raise ListingDeleted if @listing.deleted?

    unless @listing.visible_to?(@current_user, @current_community) || (@current_user && @current_user.has_admin_rights_in?(@current_community))
      if @listing.public?
        # This situation occurs when the user tries to access a listing
        # via a different community url.
        flash[:error] = t("layouts.notifications.this_content_is_not_available_in_this_community")
        redirect_to root and return
      elsif @current_user
        flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
        redirect_to root and return
      else
        session[:return_to] = request.fullpath
        flash[:warning] = t("layouts.notifications.you_must_log_in_to_view_this_content")
        redirect_to login_path and return
      end
    end
  end

  def change_follow_status(status)
    status.eql?("follow") ? @current_user.follow(@listing) : @current_user.unfollow(@listing)
    respond_to do |format|
      format.html {
        redirect_to @listing
      }
      format.js {
        render :follow, :layout => false
      }
    end
  end

  def custom_field_value_factory(custom_field_id, answer_value)
    question = CustomField.find(custom_field_id)

    answer = question.with_type do |question_type|
      case question_type
      when :dropdown
        option_id = answer_value.to_i
        answer = DropdownFieldValue.new
        answer.custom_field_option_selections = [CustomFieldOptionSelection.new(:custom_field_value => answer, :custom_field_option_id => answer_value)]
        answer
      when :text
        answer = TextFieldValue.new
        answer.text_value = answer_value
        answer
      when :numeric
        answer = NumericFieldValue.new
        answer.numeric_value = ParamsService.parse_float(answer_value)
        answer
      when :checkbox
        answer = CheckboxFieldValue.new
        answer.custom_field_option_selections = answer_value.map { |value| CustomFieldOptionSelection.new(:custom_field_value => answer, :custom_field_option_id => value) }
        answer
      when :date_field
        answer = DateFieldValue.new
        answer.date_value = DateTime.new(answer_value["(1i)"].to_i,
                                         answer_value["(2i)"].to_i,
                                         answer_value["(3i)"].to_i)
        answer
      else
        throw "Unimplemented custom field answer for question #{question_type}"
      end
    end

    answer.question = question
    answer.save
    logger.info "Errors: #{answer.errors.full_messages.inspect}"
    return answer
  end

  def create_field_values(custom_field_params)
    custom_field_params ||= {}

    mapped_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(custom_field_id, answer_value) unless is_answer_value_blank(answer_value)
    end.compact

    logger.info "Mapped values: #{mapped_values.inspect}"

    return mapped_values
  end

  def is_answer_value_blank(value)
    if value.kind_of?(Hash)
      value["(3i)"].blank? || value["(2i)"].blank? || value["(1i)"].blank?  # DateFieldValue check
    else
      value.blank?
    end
  end

  def is_authorized_to_post
    if @current_community.require_verification_to_post_listings?
      unless @current_user.has_admin_rights_in?(@current_community) || @current_community_membership.can_post_listings?
        redirect_to verification_required_listings_path
      end
    end
  end

  def numeric_field_ids(custom_fields)
    custom_fields.map do |custom_field|
      custom_field.with(:numeric) do
        custom_field.id
      end
    end.compact
  end

  def normalize_price_param(listing_params)
    if listing_params[:price] then
      listing_params.except(:price).merge(price_cents: MoneyUtil.parse_str_to_subunits(listing_params[:price], listing_params[:currency]))
    else
      listing_params
    end
  end

  def payment_setup_status(community:, user:, listing:, payment_type:)
    if payment_type == :braintree
      can_post = !PaymentRegistrationGuard.new(community, user, listing).requires_registration_before_posting?
      settings_link = payment_settings_path(community.payment_gateway.gateway_type, user)
      error_msg = t("listings.new.you_need_to_fill_payout_details_before_accepting", :payment_settings_link => view_context.link_to(t("listings.new.payment_settings_link"), settings_link)).html_safe

      [can_post, error_msg]
    elsif payment_type == :paypal
      can_post = PaypalHelper.community_ready_for_payments?(community.id)
      error_msg =
        if user.has_admin_rights_in?(community)
          t("listings.new.community_not_configured_for_payments_admin",
            payment_settings_link: view_context.link_to(
              t("listings.new.payment_settings_link"),
              admin_community_paypal_preferences_path(community_id: community.id)))
            .html_safe
        else
          t("listings.new.community_not_configured_for_payments",
            contact_admin_link: view_context.link_to(
              t("listings.new.contact_admin_link_text"),
              new_user_feedback_path))
            .html_safe
        end
      [can_post, error_msg]
    else
      [true, ""]
    end
  end

  def select_new_transaction_path(listing_id:, payment_gateway:, payment_process:, booking:)
    case [payment_process, payment_gateway, booking]
    when matches([:none])
      reply_to_listing_path(listing_id: listing_id)
    when matches([:preauthorize, __, true])
      book_path(listing_id: listing_id)
    when matches([:preauthorize, :paypal])
      initiate_order_path(listing_id: listing_id)
    when matches([:preauthorize, :braintree])
      preauthorize_payment_path(:listing_id => @listing.id.to_s)
    when matches([:postpay])
      post_pay_listing_path(:listing_id => @listing.id.to_s)
    else
      params = "listing_id: #{listing_id}, payment_gateway: #{payment_gateway}, payment_process: #{payment_process}, booking: #{booking}"
      raise ArgumentError.new("Can not find new transaction path to params")
    end
  end

  def delivery_config(require_shipping_address, pickup_enabled, shipping_price, currency)
    shipping = { name: :shipping, price: shipping_price, default: true }
    pickup = { name: :pickup, price: Money.new(0, currency), default: false }

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

  def create_listing_params(listing_params)
    listing_params.except(:delivery_methods).tap do |l|
      l[:require_shipping_address] = Maybe(listing_params[:delivery_methods]).map { |d| d.include?("shipping") }.or_else(false)
      l[:pickup_enabled] = Maybe(listing_params[:delivery_methods]).map { |d| d.include?("pickup") }.or_else(false)
    end
  end

  def get_transaction_process(community: community, listing: listing)
    opts = {
      process_id: listing.transaction_type.transaction_process_id,
      community_id: community.id
    }

    TransactionService::API::Api.processes.get(opts)
      .maybe[:process]
      .or_else(nil)
      .tap { |process|
        raise ArgumentError.new("Can not find transaction process: #{opts}") if process.nil?
      }
  end
end
