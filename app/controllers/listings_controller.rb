class ListingsController < ApplicationController
  include PeopleHelper
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:close, :update, :follow, :unfollow]

  before_filter :only => [ :edit, :update, :close, :follow, :unfollow ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_create_new_listing", :sign_up_link => view_context.link_to(t("layouts.notifications.create_one_here"), sign_up_path)).html_safe
  end
  
  before_filter :person_belongs_to_current_community, :only => [:index]
  before_filter :save_current_path, :only => :show
  before_filter :ensure_authorized_to_view, :only => [ :show, :follow, :unfollow ]
  
  before_filter :only => [ :close ] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_close_a_listing")
  end
  
  before_filter :only => [ :edit, :update ] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_edit_a_listing")
  end
  
  skip_filter :dashboard_only
  
  def index
    if params[:format] == "atom" # API request for feed
      redirect_to :controller => "Api::ListingsController", :action => :index
      return
    end
    @selected_tribe_navi_tab = "home"
    if request.xhr? && params[:person_id] # AJAX request to load on person's listings for profile view
      # Returns the listings for one person formatted for profile page view
      per_page = params[:per_page] || 200 # the point is to show all here by default
      page = params[:page] || 1
      render :partial => "listings/profile_listings", :locals => {:person => @person, :limit => per_page}
      return
    end
    redirect_to root
  end
  
  def requests
    redirect_to root
  end
  
  def offers
    redirect_to root
  end
  
  # method for serving Listing data (with locations) as JSON through AJAX-requests.
  def locations_json
    params[:include] = :origin_loc
    params.delete("controller")
    params.delete("action")
    params["custom_field_options"] = JSON.parse(params["custom_field_options"]) if params["custom_field_options"].present?
    # Limit the amount of listings to get to 500 newest to avoid slowing down the map too much.
    @listings = Listing.find_with(params, @current_user, @current_community, 500)
    render :json => { :data => @listings }
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
    @listings = Listing.visible_to(@current_user, @current_community, params[:ids]).order("id DESC")
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
  end
  
  def new
    @seller_commission = @current_community.payment_gateway.seller_pays_commission? if @current_community.payments_in_use?
    @selected_tribe_navi_tab = "new_listing"
    @listing = Listing.new
    @listing.category = Category.find_by_name(params[:subcategory].blank? ? params[:category] : params[:subcategory])
    @listing.transaction_type = TransactionType.find(params[:transaction_type])
    
    if (@current_user.location != nil)
      temp = @current_user.location
      temp.location_type = "origin_loc"
      @listing.build_origin_loc(temp.attributes)
    else
      @listing.build_origin_loc(:location_type => "origin_loc")
    end

    1.times { @listing.listing_images.build }

    if request.xhr? # AJAX request to get the actual form contents
      @community_category = @current_community.community_category(@listing.category.top_level_parent, @listing.share_type)
      render :partial => "listings/form/form_content" 
    else
      render
    end
  end

  def send_payment_settings_reminder?(community_category, listing, current_user, current_community)
    community_category.payment? &&
      listing.share_type.is_offer? &&
      current_community.payments_in_use? &&
      !@current_user.can_receive_payments_at?(@current_community)
  end
  
  def create
    if params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin_loc_attributes][:address].blank?
      params[:listing].delete("origin_loc_attributes")
    end
    @listing = @current_user.create_listing params[:listing]

    @listing.custom_field_values = create_field_values(params[:custom_fields]) if params[:custom_fields]

    if @listing.new_record?
      1.times { @listing.listing_images.build } if @listing.listing_images.empty?
      render :action => :new
    else
      path = new_request_category_path(:type => @listing.listing_type, :category => @listing.category.name)
      flash[:notice] = t("layouts.notifications.listing_created_successfully", :new_listing_link => view_context.link_to(t("layouts.notifications.create_new_listing"), path)).html_safe
      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.id))

      community_category = @current_community.community_category(@listing.category.top_level_parent, @listing.share_type)

      # Send reminder about missing payment information
      if send_payment_settings_reminder?(community_category, @listing, @current_user, @current_community)
        PersonMailer.payment_settings_reminder(@listing, @listing.author, @current_community).deliver
      end

      redirect_to @listing
    end
  end
  
  def edit
    @seller_commission = @current_community.payment_gateway.seller_pays_commission? if @current_community.payments_in_use?
    @selected_tribe_navi_tab = "home"
	  if !@listing.origin_loc
	      @listing.build_origin_loc(:location_type => "origin_loc")
	  end
    1.times { @listing.listing_images.build } if @listing.listing_images.empty?
  end
  
  def update
    if (params[:listing][:origin] && (params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin].blank?))
      params[:listing].delete("origin_loc_attributes")
      if @listing.origin_loc
        @listing.origin_loc.delete
      end
    end

    @listing.custom_field_values = create_field_values(params[:custom_fields]) if params[:custom_fields]

    if @listing.update_fields(params[:listing])
      @listing.location.update_attributes(params[:location]) if @listing.location
      flash[:notice] = t("layouts.notifications.listing_updated_successfully")
      Delayed::Job.enqueue(ListingUpdatedJob.new(@listing.id, @current_community.id))
      redirect_to @listing
    else
      render :action => :edit
    end    
  end
  
  def close
    @listing.update_attribute(:open, false)
    respond_to do |format|
      format.html {
        redirect_to @listing 
      }
      format.js {
        render :layout => false 
      }
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
  
  private
  
  # Ensure that only users with appropriate visibility settings can view the listing
  def ensure_authorized_to_view
    @listing = Listing.find(params[:id])
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
    answer = CustomFieldValue.new()
    answer.question = question

    question.with_type { |question_type|
      case question_type
      when :dropdown
        option_id = answer_value.to_i
        answer.custom_field_option_selections = [CustomFieldOptionSelection.new(:custom_field_value => answer, :custom_field_option_id => answer_value)]
        answer
      when :text_field
        answer.text_value = answer_value
        answer
      else
        throw "Unimplemented custom field answer for question #{question_type}"
      end
    }
  end

  def create_field_values(custom_field_params={})
    mapped_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(custom_field_id, answer_value) unless answer_value.blank?
    end.compact
    
    return mapped_values
  end

end
