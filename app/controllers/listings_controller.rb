# rubocop:disable ClassLength
class ListingsController < ApplicationController
  class ListingDeleted < StandardError; end

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_action :verify_authenticity_token, :only => [:close, :update, :follow, :unfollow]

  before_action :only => [ :edit, :edit_form_content, :update, :close, :follow, :unfollow ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end

  before_action :only => [ :new, :new_form_content, :create ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_create_new_listing", :sign_up_link => view_context.link_to(t("layouts.notifications.create_one_here"), sign_up_path)).html_safe
  end

  before_action :save_current_path, :only => :show
  before_action :ensure_authorized_to_view, :only => [ :show, :follow, :unfollow ]

  before_action :only => [ :close ] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_close_a_listing")
  end

  before_action :only => [ :edit, :edit_form_content, :update ] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_edit_a_listing")
  end

  before_action :ensure_is_admin, :only => [ :move_to_top, :show_in_updates_email ]

  before_action :is_authorized_to_post, :only => [ :new, :create ]

  def index
    @selected_tribe_navi_tab = "home"

    respond_to do |format|
      # Keep format.html at top, as order is important for HTTP_ACCEPT headers with '*/*'
      format.html do

        # Username is passed in person_id parameter for historical reasons.
        # In the future the actual parameter name should be changed to better
        # express its purpose. However this is a large change as there are quite a few
        # resources nested under the people resource.
        username = params[:person_id]

        if request.xhr? && username # AJAX request to load on person's listings for profile view
          @person = Person.find_by!(username: username, community_id: @current_community.id)

          # Returns the listings for one person formatted for profile page view
          per_page = params[:per_page] || 1000 # the point is to show all here by default
          includes = [:author, :listing_images]
          include_closed = @person == @current_user && params[:show_closed]
          search = {
            author_id: @person.id,
            include_closed: include_closed,
            page: 1,
            per_page: per_page
          }

          raise_errors = Rails.env.development?

          listings =
            ListingIndexService::API::Api
            .listings
            .search(
              community_id: @current_community.id,
              search: search,
              engine: FeatureFlagHelper.search_engine,
              raise_errors: raise_errors,
              includes: includes
            ).and_then { |res|
            Result::Success.new(
              ListingIndexViewUtils.to_struct(
              result: res,
              includes: includes,
              page: search[:page],
              per_page: search[:per_page]
            ))
            }.data

          render :partial => "listings/profile_listings", :locals => {person: @person, limit: per_page, listings: listings}
        else
          redirect_to search_path
        end
      end

      format.atom do
        page =  params[:page] || 1
        per_page = params[:per_page] || 50

        all_shapes = get_shapes()
        all_processes = get_processes()
        direction_map = ListingShapeHelper.shape_direction_map(all_shapes, all_processes)

        if params[:share_type].present?
          direction = params[:share_type]
          params[:listing_shapes] =
            all_shapes.select { |shape|
              direction_map[shape[:id]] == direction
            }.map { |shape| shape[:id] }
        end
        raise_errors = Rails.env.development?

        search_res = if @current_community.private
                       Result::Success.new({count: 0, listings: []})
                     else
                       ListingIndexService::API::Api
                         .listings
                         .search(
                           community_id: @current_community.id,
                           search: {
                             listing_shape_ids: params[:listing_shapes],
                             page: page,
                             per_page: per_page
                           },
                           engine: FeatureFlagHelper.search_engine,
                           raise_errors: raise_errors,
                           includes: [:listing_images, :author, :location])
                     end

        listings = search_res.data[:listings]

        title = build_title(params)
        updated = listings.first.present? ? listings.first[:updated_at] : Time.now

        render layout: false,
               locals: { listings: listings,
                         title: title,
                         updated: updated,

                         # deprecated
                         direction_map: direction_map
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

    @listings = if @current_user || !@current_community.private?
      @current_community.listings.where(listings: {id: ids}).order("listings.created_at DESC")
    else
      []
    end

    if !@listings.empty?
      render :partial => "homepage/listing_bubble_multiple"
    else
      render :partial => "bubble_listing_not_visible"
    end
  end

  def show
    @selected_tribe_navi_tab = "home"

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
    process = get_transaction_process(community_id: @current_community.id, transaction_process_id: @listing.transaction_process_id)
    form_path = new_transaction_path(listing_id: @listing.id)
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    delivery_opts = delivery_config(@listing.require_shipping_address, @listing.pickup_enabled, @listing.shipping_price, @listing.shipping_price_additional, @listing.currency)

    received_testimonials = TestimonialViewUtils.received_testimonials_in_community(@listing.author, @current_community)
    received_positive_testimonials = TestimonialViewUtils.received_positive_testimonials_in_community(@listing.author, @current_community)
    feedback_positive_percentage = @listing.author.feedback_positive_percentage_in_community(@current_community)

    youtube_link_ids = ListingViewUtils.youtube_video_ids(@listing.description)

    onboarding_popup_locals = OnboardingViewUtils.popup_locals(
      flash[:show_onboarding_popup],
      admin_getting_started_guide_path,
      Admin::OnboardingWizard.new(@current_community.id).setup_status)

    availability_enabled = @listing.availability.to_sym == :booking
    blocked_dates_start_on = 1.day.ago.to_date
    blocked_dates_end_on = 12.months.from_now.to_date

    blocked_dates_result =
      if availability_enabled

        get_blocked_dates(
          start_on: blocked_dates_start_on,
          end_on: blocked_dates_end_on,
          community: @current_community,
          user: @current_user,
          listing: @listing)
      else
        Result::Success.new([])
      end

    currency = Maybe(@listing.price).currency.or_else(Money::Currency.new(@current_community.currency))

    view_locals = {
      form_path: form_path,
      payment_gateway: payment_gateway,
      # TODO I guess we should not need to know the process in order to show the listing
      process: process,
      delivery_opts: delivery_opts,
      listing_unit_type: @listing.unit_type,
      country_code: community_country_code,
      received_testimonials: received_testimonials,
      received_positive_testimonials: received_positive_testimonials,
      feedback_positive_percentage: feedback_positive_percentage,
      youtube_link_ids: youtube_link_ids,
      manage_availability_props: manage_availability_props(@current_community, @listing),
      availability_enabled: availability_enabled,
      blocked_dates_result: blocked_dates_result,
      blocked_dates_end_on: DateUtils.to_midnight_utc(blocked_dates_end_on),
      currency_opts: MoneyViewUtils.currency_opts(I18n.locale, currency)
    }

    Analytics.record_event(
      flash.now,
      "ListingViewed",
      { listing_id: @listing.id,
        listing_uuid: @listing.uuid_object.to_s,
        payment_process: process })

    render(locals: onboarding_popup_locals.merge(view_locals))
  end

  def new
    category_tree = CategoryViewUtils.category_tree(
      categories: ListingService::API::Api.categories.get_all(community_id: @current_community.id)[:data],
      shapes: get_shapes,
      locale: I18n.locale,
      all_locales: @current_community.locales
    )

    render :new, locals: {
             categories: @current_community.top_level_categories,
             subcategories: @current_community.subcategories,
             shapes: get_shapes,
             category_tree: category_tree
           }
  end

  def new_form_content
    return redirect_to action: :new unless request.xhr?

    @listing = Listing.new

    if !@current_user.location.nil?
      temp = @current_user.location
      @listing.build_origin_loc(temp.attributes)
    else
      @listing.build_origin_loc()
    end

    form_content
  end

  def edit_form_content
    return redirect_to action: :edit unless request.xhr?

    unless @listing.origin_loc
        @listing.build_origin_loc()
    end

    form_content
  end

  def create
    params[:listing].delete("origin_loc_attributes") if params[:listing][:origin_loc_attributes][:address].blank?

    shape = get_shape(Maybe(params)[:listing][:listing_shape_id].to_i.or_else(nil))
    listing_uuid = UUIDUtils.create

    if shape.present? && shape[:availability] == :booking
      bookable_res = create_bookable(@current_community.uuid_object, listing_uuid, @current_user.uuid_object)
      unless bookable_res.success
        flash[:error] = t("listings.error.create_failed_to_connect_to_booking_service")
        return redirect_to new_listing_path
      end
    end

    create_listing(shape, listing_uuid)
  end


  # rubocop:disable Metrics/AbcSize
  def create_listing(shape, listing_uuid)
    with_currency = params.to_unsafe_hash[:listing].merge({currency: @current_community.currency})
    valid_until_enabled = !@current_community.hide_expiration_date
    listing_params = ListingFormViewUtils.filter(with_currency, shape, valid_until_enabled)
    listing_unit = Maybe(params.to_unsafe_hash)[:listing][:unit].map { |u| ListingViewUtils::Unit.deserialize(u) }.or_else(nil)
    listing_params = ListingFormViewUtils.filter_additional_shipping(listing_params, listing_unit)
    validation_result = ListingFormViewUtils.validate(
      params: listing_params,
      shape: shape,
      unit: listing_unit,
      valid_until_enabled: valid_until_enabled
    )

    unless validation_result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: validation_result.data.join(', '))
      return redirect_to new_listing_path
    end

    listing_params = normalize_price_params(listing_params)
    m_unit = select_unit(listing_unit, shape)

    listing_params = create_listing_params(listing_params).merge(
        uuid_object: listing_uuid,
        community_id: @current_community.id,
        listing_shape_id: shape[:id],
        transaction_process_id: shape[:transaction_process_id],
        shape_name_tr_key: shape[:name_tr_key],
        action_button_tr_key: shape[:action_button_tr_key],
        availability: shape[:availability]
    ).merge(unit_to_listing_opts(m_unit)).except(:unit)

    @listing = Listing.new(listing_params)

    ActiveRecord::Base.transaction do
      @listing.author = @current_user

      if @listing.save
        upsert_field_values!(@listing, params.to_unsafe_hash[:custom_fields])

        listing_image_ids =
          if params[:listing_images]
            params[:listing_images].collect { |h| h[:id] }.select { |id| id.present? }
          else
            logger.error("Listing images array is missing", nil, {params: params})
            []
          end

        ListingImage.where(id: listing_image_ids, author_id: @current_user.id).update_all(listing_id: @listing.id)

        if params[:listing_ordered_images].present?
          params[:listing_ordered_images].split(",").each_with_index do |image_id, position|
            ListingImage.where(id: image_id, author_id: @current_user.id).update_all(position: position+1)
          end
        end

        Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.id))
        if @current_community.follow_in_use?
          Delayed::Job.enqueue(NotifyFollowersJob.new(@listing.id, @current_community.id), :run_at => NotifyFollowersJob::DELAY.from_now)
        end

        flash[:notice] = t(
          "layouts.notifications.listing_created_successfully",
          :new_listing_link => view_context.link_to(t("layouts.notifications.create_new_listing"),new_listing_path)
        ).html_safe

        # Onboarding wizard step recording
        state_changed = Admin::OnboardingWizard.new(@current_community.id)
          .update_from_event(:listing_created, @listing)
        if state_changed
          report_to_gtm({event: "km_record", km_event: "Onboarding listing created"})

          flash[:show_onboarding_popup] = true
        end

        if shape[:availability] == :booking
          redirect_to listing_path(@listing, anchor: 'manage-availability'), status: 303 and return
        end

        redirect_to @listing, status: 303 and return
      else
        logger.error("Errors in creating listing: #{@listing.errors.full_messages.inspect}")
        flash[:error] = t(
          "layouts.notifications.listing_could_not_be_saved",
          :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")
        ).html_safe
        redirect_to new_listing_path and return
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    @selected_tribe_navi_tab = "home"
    unless @listing.origin_loc
        @listing.build_origin_loc()
    end

    @custom_field_questions = @listing.category.custom_fields.where(community_id: @current_community.id)
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    shape = select_shape(get_shapes, @listing.listing_shape_id)

    if shape
      @listing.listing_shape_id = shape[:id]
    end

    category_tree = CategoryViewUtils.category_tree(
      categories: ListingService::API::Api.categories.get_all(community_id: @current_community.id)[:data],
      shapes: get_shapes,
      locale: I18n.locale,
      all_locales: @current_community.locales
    )

    category_id, subcategory_id =
      if @listing.category.parent_id
        [@listing.category.parent_id, @listing.category.id]
      else
        [@listing.category.id, nil]
      end

    render locals: {
             category_tree: category_tree,
             categories: @current_community.top_level_categories,
             subcategories: @current_community.subcategories,
             shapes: get_shapes,
             category_id: category_id,
             subcategory_id: subcategory_id,
             shape_id: @listing.listing_shape_id,
             form_content: form_locals(shape)
           }
  end

  def update
    if (params[:listing][:origin] && (params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin].blank?))
      params[:listing].delete("origin_loc_attributes")
      if @listing.origin_loc
        @listing.origin_loc.delete
      end
    end

    shape = get_shape(params[:listing][:listing_shape_id])

    if shape.present? && shape[:availability] == :booking
      bookable_res = create_bookable(@current_community.uuid_object, @listing.uuid_object, @current_user.uuid_object)
      unless bookable_res.success
        flash[:error] = t("listings.error.update_failed_to_connect_to_booking_service")
        return redirect_to edit_listing_path(@listing)
      end
    end

    valid_until_enabled = !@current_community.hide_expiration_date
    with_currency = params.require(:listing).merge({currency: @current_community.currency}).permit!.to_h
    listing_params = ListingFormViewUtils.filter(with_currency, shape, valid_until_enabled)
    listing_unit = Maybe(params)[:listing][:unit].map { |u| ListingViewUtils::Unit.deserialize(u) }.or_else(nil)
    listing_params = ListingFormViewUtils.filter_additional_shipping(listing_params, listing_unit)
    validation_result = ListingFormViewUtils.validate(
      params: listing_params,
      shape: shape,
      unit: listing_unit,
      valid_until_enabled: valid_until_enabled
    )

    unless validation_result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: validation_result.data.join(', '))
      return redirect_to edit_listing_path
    end

    listing_params = normalize_price_params(listing_params)
    m_unit = select_unit(listing_unit, shape)
    listing_reopened = @listing.closed?

    open_params = listing_reopened ? {open: true} : {}

    listing_params = create_listing_params(listing_params).merge(
      transaction_process_id: shape[:transaction_process_id],
      shape_name_tr_key: shape[:name_tr_key],
      action_button_tr_key: shape[:action_button_tr_key],
      last_modified: DateTime.now,
      availability: shape[:availability]
    ).merge(open_params).merge(unit_to_listing_opts(m_unit)).except(:unit)

    old_availability = @listing.availability.to_sym
    update_successful = @listing.update_fields(listing_params)

    upsert_field_values!(@listing, params.to_unsafe_hash[:custom_fields])
    finalise_update(@listing, shape, @current_community, update_successful, old_availability)
  end

  def finalise_update(listing, shape, community, update_successful, old_availability)
    if update_successful
      if listing.location
        location_params = permit_location_params(params)
        listing.location.update_attributes(location_params)
      end
      flash[:notice] = update_flash(old_availability: old_availability, new_availability: shape[:availability])
      Delayed::Job.enqueue(ListingUpdatedJob.new(listing.id, community.id))
      reprocess_missing_image_styles(listing) if listing.closed?
      redirect_to listing
    else
      logger.error("Errors in editing listing: #{listing.errors.full_messages.inspect}")
      flash[:error] = t("layouts.notifications.listing_could_not_be_saved", :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")).html_safe
      redirect_to edit_listing_path(listing)
    end
  end

  def close
    process = get_transaction_process(community_id: @current_community.id, transaction_process_id: @listing.transaction_process_id)

    payment_gateway = MarketplaceService::Community::Query.payment_type(@current_community.id)
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    @listing.update_attribute(:open, false)
    respond_to do |format|
      format.html {
        redirect_to @listing
      }
      format.js {
        render :layout => false, locals: {payment_gateway: payment_gateway, process: process, country_code: community_country_code, availability_enabled: @listing.availability.to_sym == :booking }
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
      logger.error("An error occured while trying to move the listing (id=#{Maybe(@listing).id.or_else('No id available')}) to the top of the homepage")
      redirect_to @listing
    end
  end

  def show_in_updates_email
    @listing = @current_community.listings.find(params[:id])

    # Listings are sorted by `created_at`, so change it to now.
    if @listing.update_attribute(:updates_email_at, Time.now)
      render :body => nil, :status => 200
    else
      logger.error("An error occured while trying to move the listing (id=#{Maybe(@listing).id.or_else('No id available')}) to the top of the homepage")
      render :body => nil, :status => 500
    end
  end

  def ensure_current_user_is_listing_author(error_message)
    @listing = Listing.find(params[:id])
    return if current_user?(@listing.author) || @current_user.has_admin_rights?(@current_community)
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

  def update_flash(old_availability:, new_availability:)
    case [new_availability.to_sym == :booking, old_availability.to_sym == :booking]
    when [true, false]
      t("layouts.notifications.listing_updated_availability_management_enabled")
    when [false, true]
      t("layouts.notifications.listing_updated_availability_management_disabled")
    else
      t("layouts.notifications.listing_updated_successfully")
    end
  end

  def create_bookable(community_uuid, listing_uuid, author_uuid)
    res = HarmonyClient.post(
      :create_bookable,
      body: {
        marketplaceId: community_uuid,
        refId: listing_uuid,
        authorId: author_uuid
      },
      opts: {
        max_attempts: 3
      })

    if !res[:success] && res[:data][:status] == 409
      Result::Success.new("Bookable for listing with UUID #{listing_uuid} already created")
    else
      res
    end
  end

  def get_blocked_dates(start_on:, end_on:, community:, user:, listing:)
    HarmonyClient.get(
      :query_timeslots,
      params: {
        marketplaceId: community.uuid_object,
        refId: listing.uuid_object,
        start: start_on,
        end: end_on
      }
    ).rescue {
      Result::Error.new(nil, code: :harmony_api_error)
    }.and_then { |res|
      available_slots = dates_to_ts_set(
        res[:body][:data].map { |timeslot| timeslot[:attributes][:start].to_date }
      )
      Result::Success.new(
        dates_to_ts_set(start_on..end_on).subtract(available_slots)
      )
    }
  end

  def dates_to_ts_set(dates)
    Set.new(dates.map { |d| DateUtils.to_midnight_utc(d) })
  end

  def select_shape(shapes, id)
    if shapes.size == 1
      shapes.first
    else
      shapes.find { |shape| shape[:id] == id }
    end
  end

  def form_locals(shape)
    if shape
      process = get_transaction_process(community_id: @current_community.id, transaction_process_id: shape[:transaction_process_id])
      unit_options = ListingViewUtils.unit_options(shape[:units], unit_from_listing(@listing))

      shipping_price_additional =
        if @listing.shipping_price_additional
          @listing.shipping_price_additional.to_s
        elsif @listing.shipping_price
          @listing.shipping_price.to_s
        else
          0
        end

      community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
      community_currency = Money::Currency.new(@current_community.currency)

      commission(@current_community, process).merge({
        shape: shape,
        unit_options: unit_options,
        shipping_price: Maybe(@listing).shipping_price.or_else(0).to_s,
        shipping_enabled: @listing.require_shipping_address?,
        pickup_enabled: @listing.pickup_enabled?,
        shipping_price_additional: shipping_price_additional,
        always_show_additional_shipping_price: shape[:units].length == 1 && shape[:units].first[:kind] == :quantity,
        paypal_fees_url: PaypalCountryHelper.fee_link(community_country_code),
        stripe_fees_url: "https://stripe.com/#{community_country_code.downcase}/pricing",
        currency_opts: MoneyViewUtils.currency_opts(I18n.locale, community_currency)
      })
    end
  end

  def form_content
    @listing.category = @current_community.categories.find(params[:subcategory].blank? ? params[:category] : params[:subcategory])
    @custom_field_questions = @listing.category.custom_fields
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    shape = get_shape(Maybe(params)[:listing_shape].to_i.or_else(nil))
    process = get_transaction_process(community_id: @current_community.id, transaction_process_id: shape[:transaction_process_id])

    # PaymentRegistrationGuard needs this to be set before posting
    @listing.transaction_process_id = shape[:transaction_process_id]
    @listing.listing_shape_id = shape[:id]

    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)
    allow_posting, error_msg = payment_setup_status(
                     community: @current_community,
                     user: @current_user,
                     listing: @listing,
                     payment_type: payment_type,
                     process: process)

    if allow_posting
      render :partial => "listings/form/form_content", locals: form_locals(shape).merge(
               run_js_immediately: true
             )
    else
      render :partial => "listings/payout_registration_before_posting", locals: { error_msg: error_msg }
    end
  end

  def select_unit(listing_unit, shape)
    Maybe(shape)[:units].map { |units|
      units.length == 1 ? units.first : units.find { |u| u == listing_unit }
    }
  end

  def unit_to_listing_opts(m_unit)
    m_unit.map { |unit|
      {
        unit_type: unit[:type],
        quantity_selector: unit[:quantity_selector],
        unit_tr_key: unit[:name_tr_key],
        unit_selector_tr_key: unit[:selector_tr_key]
      }
    }.or_else({
        unit_type: nil,
        quantity_selector: nil,
        unit_tr_key: nil,
        unit_selector_tr_key: nil
    })
  end

  def unit_from_listing(listing)
    HashUtils.compact({
      type: Maybe(listing.unit_type).to_sym.or_else(nil),
      quantity_selector: Maybe(listing.quantity_selector).to_sym.or_else(nil),
      unit_tr_key: listing.unit_tr_key,
      unit_selector_tr_key: listing.unit_selector_tr_key
    })
  end

  def build_title(params)
    category = Category.find_by_id(params["category"])
    category_label = (category.present? ? "(" + localized_category_label(category) + ")" : "")

    listing_type_label = if ["request","offer"].include? params['share_type']
      t("listings.index.#{params['share_type']+"s"}")
    else
      t("listings.index.listings")
    end

    t("listings.index.feed_title",
      :optional_category => category_label,
      :community_name => @current_community.name_with_separator(I18n.locale),
      :listing_type => listing_type_label)
  end

  def commission(community, process)
    payment_type = MarketplaceService::Community::Query.payment_type(community.id)
    currency = community.currency

    case [payment_type, process]
    when matches([__, :none])
      {seller_commission_in_use: false,
       payment_gateway: nil,
       minimum_commission: Money.new(0, currency),
       commission_from_seller: 0,
       minimum_price_cents: 0}
    when matches([:paypal]), matches([:stripe]), matches([ [:paypal, :stripe] ])
      p_set = Maybe(payment_settings_api.get_active_by_gateway(community_id: community.id, payment_gateway: payment_type))
        .select {|res| res[:success]}
        .map {|res| res[:data]}
        .or_else({})

      {seller_commission_in_use: p_set[:commission_type] != :none,
       payment_gateway: payment_type,
       minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
       commission_from_seller: p_set[:commission_from_seller],
       minimum_price_cents: p_set[:minimum_price_cents]}
    else
      raise ArgumentError.new("Unknown payment_type, process combination: [#{payment_type}, #{process}]")
    end
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  # Ensure that only users with appropriate visibility settings can view the listing
  def ensure_authorized_to_view
    # If listing is not found (in this community) the find method
    # will throw ActiveRecord::NotFound exception, which is handled
    # correctly in production environment (404 page)
    @listing = @current_community.listings.find(params[:id])

    raise ListingDeleted if @listing.deleted?

    unless @listing.visible_to?(@current_user, @current_community)
      if @current_user
        flash[:error] = if @listing.closed?
          t("layouts.notifications.listing_closed")
        else
          t("layouts.notifications.you_are_not_authorized_to_view_this_content")
        end
        redirect_to search_path and return
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

  def custom_field_value_factory(listing_id, custom_field_id, answer_value)
    question = CustomField.find(custom_field_id)

    answer = question.with_type do |question_type|
      case question_type
      when :dropdown
        option_id = answer_value.to_i
        answer = DropdownFieldValue.new
        answer.custom_field_option_selections = [CustomFieldOptionSelection.new(:custom_field_value => answer,
                                                                                :custom_field_option_id => option_id,
                                                                                :listing_id => listing_id)]
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
        answer.custom_field_option_selections = answer_value.map { |value|
          CustomFieldOptionSelection.new(:custom_field_value => answer, :custom_field_option_id => value, :listing_id => listing_id)
        }
        answer
      when :date_field
        answer = DateFieldValue.new
        answer.date_value = Time.utc(answer_value["(1i)"].to_i,
                                     answer_value["(2i)"].to_i,
                                     answer_value["(3i)"].to_i)
        answer
      else
        raise ArgumentError.new("Unimplemented custom field answer for question #{question_type}")
      end
    end

    answer.question = question
    answer.listing_id = listing_id
    return answer
  end

  # Note! Requires that parent listing is already saved to DB. We
  # don't use association to link to listing but directly connect to
  # listing_id.
  def upsert_field_values!(listing, custom_field_params)
    custom_field_params ||= {}

    # Delete all existing
    custom_field_value_ids = listing.custom_field_values.map(&:id)
    CustomFieldOptionSelection.where(custom_field_value_id: custom_field_value_ids).delete_all
    CustomFieldValue.where(id: custom_field_value_ids).delete_all

    field_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(listing.id, custom_field_id, answer_value) unless is_answer_value_blank(answer_value)
    end.compact

    # Insert new custom fields in a single transaction
    CustomFieldValue.transaction do
      field_values.each(&:save!)
    end
  end

  def is_answer_value_blank(value)
    if value.is_a?(Hash)
      value["(3i)"].blank? || value["(2i)"].blank? || value["(1i)"].blank?  # DateFieldValue check
    else
      value.blank?
    end
  end

  def is_authorized_to_post
    if @current_community.require_verification_to_post_listings?
      unless @current_user.has_admin_rights?(@current_community) || @current_community_membership.can_post_listings?
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

  def normalize_price_params(listing_params)
    currency = listing_params[:currency]
    listing_params.inject({}) do |hash, (k, v)|
      case k
      when "price"
        hash.merge(:price_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      when "shipping_price"
        hash.merge(:shipping_price_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      when "shipping_price_additional"
        hash.merge(:shipping_price_additional_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      else
        hash.merge(k.to_sym => v)
      end
    end
  end

  def payment_setup_status(community:, user:, listing:, payment_type:, process:)
    case [payment_type, process]
    when matches([nil]),
         matches([__, :none])
      [true, ""]
    when matches([:paypal])
      can_post = PaypalHelper.community_ready_for_payments?(community.id)
      error_msg =
        if user.has_admin_rights?(community)
          t("listings.new.community_not_configured_for_payments_admin",
            payment_settings_link: view_context.link_to(
              t("listings.new.payment_settings_link"),
              admin_payment_preferences_path()))
            .html_safe
        else
          t("listings.new.community_not_configured_for_payments",
            contact_admin_link: view_context.link_to(
              t("listings.new.contact_admin_link_text"),
              new_user_feedback_path))
            .html_safe
        end
      [can_post, error_msg]
    when matches([:stripe])
      can_post = StripeHelper.community_ready_for_payments?(community.id)
      error_msg =
        if user.has_admin_rights?(community)
          t("listings.new.community_not_configured_for_payments_admin",
            payment_settings_link: view_context.link_to(
              t("listings.new.payment_settings_link"),
              admin_payment_preferences_path()))
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

  def create_listing_params(params)
    listing_params = params.except(:delivery_methods).merge(
      require_shipping_address: Maybe(params[:delivery_methods]).map { |d| d.include?("shipping") }.or_else(false),
      pickup_enabled: Maybe(params[:delivery_methods]).map { |d| d.include?("pickup") }.or_else(false),
      price_cents: params[:price_cents],
      shipping_price_cents: params[:shipping_price_cents],
      shipping_price_additional_cents: params[:shipping_price_additional_cents],
      currency: params[:currency]
    )

    add_location_params(listing_params, params)
  end

  def add_location_params(listing_params, params)
    if params[:origin_loc_attributes].nil?
      listing_params
    else
      params = ActionController::Parameters.new(params)
      location_params = permit_location_params(params).merge(location_type: :origin_loc)

      listing_params.merge(
        origin_loc_attributes: location_params
      )
    end
  end

  def permit_location_params(params)
    p = if params[:location].present?
          params.require(:location)
        elsif params[:origin_loc_attributes].present?
          params.require(:origin_loc_attributes)
        elsif params[:listing].present? && params[:listing][:origin_loc_attributes].present?
          params.require(:listing).require(:origin_loc_attributes)
        end
    p.permit(:address, :google_address, :latitude, :longitude) if p.present?
  end

  def get_transaction_process(community_id:, transaction_process_id:)
    opts = {
      process_id: transaction_process_id,
      community_id: community_id
    }

    TransactionService::API::Api.processes.get(opts)
      .maybe[:process]
      .or_else(nil)
      .tap { |process|
        raise ArgumentError.new("Cannot find transaction process: #{opts}") if process.nil?
      }
  end

  def listings_api
    ListingService::API::Api
  end

  def transactions_api
    TransactionService::API::Api
  end

  def valid_unit_type?(shape:, unit_type:)
    if unit_type.nil?
      shape[:units].empty?
    else
      shape[:units].any? { |unit| unit[:type] == unit_type.to_sym }
    end
  end

  def get_shapes
    @shapes ||= listings_api.shapes.get(community_id: @current_community.id).maybe.or_else(nil).tap { |shapes|
      raise ArgumentError.new("Cannot find any listing shape for community #{@current_community.id}") if shapes.nil?
    }
  end

  def get_processes
    @processes ||= transactions_api.processes.get(community_id: @current_community.id).maybe.or_else(nil).tap { |processes|
      raise ArgumentError.new("Cannot find any transaction process for community #{@current_community.id}") if processes.nil?
    }
  end

  def get_shape(listing_shape_id)
    shape_find_opts = {
      community_id: @current_community.id,
      listing_shape_id: listing_shape_id
    }

    shape_res = listings_api.shapes.get(shape_find_opts)

    if shape_res.success
      shape_res.data
    else
      raise ArgumentError.new(shape_res.error_msg) unless shape_res.success
    end
  end

  def delivery_price_hash(delivery_type, price, shipping_price_additional)
      { name: delivery_type,
        price: price,
        shipping_price_additional: shipping_price_additional,
        price_info: ListingViewUtils.shipping_info(delivery_type, price, shipping_price_additional),
        default: true
      }
  end

  # Create image sizes that might be missing
  # from a reopened listing
  def reprocess_missing_image_styles(listing)
    listing.listing_images.pluck(:id).each { |image_id|
      Delayed::Job.enqueue(CreateSquareImagesJob.new(image_id))
    }
  end

  def manage_availability_props(community, listing)
    ManageAvailabilityHelper.availability_props(
      community: community,
      listing: listing)
  end
end
