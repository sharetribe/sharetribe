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
          listings_presenter = ListingsPersonPresenter.new(@current_community, @current_user, username, params)
          render :partial => "listings/profile_listings", locals: {
            person: listings_presenter.person, limit: listings_presenter.per_page, listings: listings_presenter.listings }
        else
          redirect_to search_path
        end
      end

      format.atom do
        @feed_presenter = ListingsFeedPresenter.new(@current_community, @current_community.shapes, @current_community.transaction_processes, params)
        render layout: false
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

  # Used to show multiple listings in one bubble
  def listing_bubble_multiple
    ids = params[:ids].split(",").map(&:to_i)

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
    make_onboarding_popup

    make_listing_presenter
    @listing_presenter.form_path = new_transaction_path(listing_id: @listing.id)

    record_event(
      flash.now,
      "ListingViewed",
      { listing_id: @listing.id,
        listing_uuid: @listing.uuid_object.to_s,
        payment_process: @listing_presenter.process })
  end

  def new
    @listing = Listing.new
    make_listing_presenter
  end

  def new_form_content
    return redirect_to action: :new unless request.xhr?

    @listing = Listing.new
    @listing.init_origin_location(@current_user.location)

    form_content
  end

  def edit_form_content
    return redirect_to action: :edit unless request.xhr?

    @listing.ensure_origin_loc

    form_content
  end

  def create
    params[:listing].delete("origin_loc_attributes") if params[:listing][:origin_loc_attributes][:address].blank?

    shape = get_shape(Maybe(params)[:listing][:listing_shape_id].to_i.or_else(nil))
    listing_uuid = UUIDUtils.create

    unless create_booking(shape, listing_uuid)
      flash[:error] = t("listings.error.create_failed_to_connect_to_booking_service")
      return redirect_to new_listing_path
    end

    result = ListingFormViewUtils.build_listing_params(shape, listing_uuid, params, @current_community)

    unless result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: result.data.join(', '))
      redirect_to new_listing_path
      return
    end

    @listing = Listing.new(result.data)

    ActiveRecord::Base.transaction do
      @listing.author = @current_user

      if @listing.save
        @listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])
        @listing.reorder_listing_images(params, @current_user.id)
        notify_about_new_listing

        if shape.booking?
          anchor = shape.booking_per_hour? ? 'manage-working-hours' : 'manage-availability'
          @listing.working_hours_new_set(force_create: true) if shape.booking_per_hour?
          redirect_to listing_path(@listing, anchor: anchor, listing_just_created: true), status: 303
        else
          redirect_to @listing, status: 303
        end
      else
        logger.error("Errors in creating listing: #{@listing.errors.full_messages.inspect}")
        flash[:error] = t(
          "layouts.notifications.listing_could_not_be_saved",
          :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")
        ).html_safe
        redirect_to new_listing_path
      end
    end
  end

  def edit
    @selected_tribe_navi_tab = "home"

    make_listing_presenter
    @listing.ensure_origin_loc

    @custom_field_questions = @listing.category.custom_fields.where(community_id: @current_community.id)
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    shape = select_shape(@current_community.shapes, @listing)
    if shape[:id]
      @listing.listing_shape_id = shape[:id]
    end
    render locals: { form_content: form_locals(shape) }
  end

  def update
    if (params[:listing][:origin] && (params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin].blank?))
      params[:listing].delete("origin_loc_attributes")
      if @listing.origin_loc
        @listing.origin_loc.delete
      end
    end

    shape = get_shape(params[:listing][:listing_shape_id])

    unless create_booking(shape, @listing.uuid_object)
      flash[:error] = t("listings.error.update_failed_to_connect_to_booking_service")
      return redirect_to edit_listing_path(@listing)
    end

    result = ListingFormViewUtils.build_listing_params(shape, @listing.uuid_object, params, @current_community)

    unless result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: result.data.join(', '))
      return redirect_to edit_listing_path
    end

    listing_params = result.data.merge(@listing.closed? ? {open: true} : {})

    old_availability = @listing.availability.to_sym
    update_successful = @listing.update_fields(listing_params)
    @listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])

    if update_successful
      if shape.booking_per_hour? && !@listing.per_hour_ready
        @listing.working_hours_new_set(force_create: true)
      end
      if @listing.location
        location_params = ListingFormViewUtils.permit_location_params(params)
        @listing.location.update_attributes(location_params)
      end
      flash[:notice] = update_flash(old_availability: old_availability, new_availability: shape[:availability])
      Delayed::Job.enqueue(ListingUpdatedJob.new(@listing.id, @current_community.id))
      reprocess_missing_image_styles(@listing) if @listing.closed?
      redirect_to @listing
    else
      logger.error("Errors in editing listing: #{@listing.errors.full_messages.inspect}")
      flash[:error] = t("layouts.notifications.listing_could_not_be_saved", :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")).html_safe
      redirect_to edit_listing_path(@listing)
    end
  end

  def close
    make_listing_presenter
    @listing.update_attribute(:open, false)
    respond_to do |format|
      format.html { redirect_to @listing }
      format.js { render :layout => false }
    end
  end

  def move_to_top
    @listing = @current_community.listings.find(params[:id])

    # Listings are sorted by `sort_date`, so change it to now.
    @listing.update_attribute(:sort_date, Time.now)
    redirect_to homepage_index_path
  end

  def show_in_updates_email
    @listing = @current_community.listings.find(params[:id])
    @listing.update_attribute(:updates_email_at, Time.now)
    render :body => nil, :status => 200
  end

  def follow
    change_follow_status("follow")
  end

  def unfollow
    change_follow_status("unfollow")
  end

  def verification_required

  end

  def ensure_current_user_is_listing_author(error_message)
    @listing = Listing.find(params[:id])
    return if current_user?(@listing.author) || @current_user.has_admin_rights?(@current_community)
    flash[:error] = error_message
    redirect_to @listing and return
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

  def select_shape(shapes, listing)
    if listing.listing_shape_id.nil?
      ListingShape.new(transaction_process_id: listing.transaction_process_id)
    elsif shapes.size == 1
      shapes.first
    else
      shapes.find { |shape| shape[:id] == listing.listing_shape_id }
    end
  end

  def form_locals(shape)
    @listing_presenter.listing_shape = shape
    {shape: shape}
  end

  def form_content
    make_listing_presenter

    @listing.category = @current_community.categories.find(params[:subcategory].blank? ? params[:category] : params[:subcategory])
    @custom_field_questions = @listing.category.custom_fields
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    shape = get_shape(Maybe(params)[:listing_shape].to_i.or_else(nil))
    process = @listing_presenter.get_transaction_process(community_id: @current_community.id, transaction_process_id: shape[:transaction_process_id])

    @listing.transaction_process_id = shape[:transaction_process_id]
    @listing.listing_shape_id = shape[:id]

    payment_type = @current_community.active_payment_types
    allow_posting, error_msg = payment_setup_status(
                     community: @current_community,
                     user: @current_user,
                     listing: @listing,
                     payment_type: payment_type,
                     process: process)

    if allow_posting
      render :partial => "listings/form/form_content", locals: form_locals(shape).merge(run_js_immediately: true)
    else
      render :partial => "listings/payout_registration_before_posting", locals: { error_msg: error_msg }
    end
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

  def payment_setup_status(community:, user:, listing:, payment_type:, process:)
    case [payment_type, process]
    when matches([nil]),
         matches([__, :none])
      [true, ""]
    when matches([:paypal])
      can_post = PaypalHelper.community_ready_for_payments?(community.id)
      error_msg = make_error_msg(user, community)
      [can_post, error_msg]
    when matches([:stripe])
      can_post = StripeHelper.community_ready_for_payments?(community.id)
      error_msg = make_error_msg(user, community)
      [can_post, error_msg]
    when matches([[:paypal, :stripe]])
      can_post = StripeHelper.community_ready_for_payments?(community.id) || PaypalHelper.community_ready_for_payments?(community.id)
      error_msg = make_error_msg(user, community)
      [can_post, error_msg]
    else
      [true, ""]
    end
  end

  def make_error_msg(user, community)
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
  end

  def get_shape(listing_shape_id)
    @current_community.shapes.find(listing_shape_id)
  end

  # Create image sizes that might be missing
  # from a reopened listing
  def reprocess_missing_image_styles(listing)
    listing.listing_image_ids.each { |image_id|
      Delayed::Job.enqueue(CreateSquareImagesJob.new(image_id))
    }
  end

  def make_listing_presenter
    @listing_presenter = ListingPresenter.new(@listing, @current_community, params, @current_user)
  end

  def notify_about_new_listing
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
      record_event(flash, "km_record", {km_event: "Onboarding listing created"}, AnalyticService::EVENT_LISTING_CREATED)

      flash[:show_onboarding_popup] = true
    end
  end

  def create_booking(shape, listing_uuid)
    if shape.present?
      if shape.booking_per_hour?
        true
      elsif APP_CONFIG.harmony_api_in_use && shape.booking?
        create_bookable(@current_community.uuid_object, listing_uuid, @current_user.uuid_object).success
      else
        true
      end
    else
      true
    end
  end
end
