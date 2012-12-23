class ListingsController < ApplicationController
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:close, :update, :follow, :unfollow]

  before_filter :only => [ :edit, :update, :close, :follow, :unfollow ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_this_content"
  end

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in(["you_must_log_in_to_create_new_#{params[:type]}", "create_one_here".to_sym, sign_up_path])
  end

  before_filter :save_current_path, :only => :show
  before_filter :ensure_authorized_to_view, :only => [ :show, :follow, :unfollow ]
  
  before_filter :only => [ :close ] do |controller|
    controller.ensure_current_user_is_listing_author "only_listing_author_can_close_a_listing"
  end
  
  before_filter :only => [ :edit, :update ] do |controller|
    controller.ensure_current_user_is_listing_author "only_listing_author_can_edit_a_listing"
  end
  
  skip_filter :dashboard_only
  
  def index
    session[:selected_tab] = "home"
    if params[:format] == "atom"
      redirect_to :controller => "Api::ListingsController", :action => :index
      return
    end
    redirect_to root
  end
  
  def requests
    params[:listing_type] = "request"
    @to_render = {:action => :index}
    @listing_style = "listing"
    load
  end
  
  def offers
    params[:listing_type] = "offer"
    @to_render = {:action => :index}
    @listing_style = "listing"
    load
  end

  # detect the browser and return the approriate layout
  def detect_browser
    if APP_CONFIG.force_mobile_ui
        return true
    end
    
    mobile_browsers = ["android", "ipod", "opera mini", "blackberry", 
"palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", 
"windows ce; smartphone;","windows ce; iemobile", 
"up.browser","up.link","mmp","symbian","smartphone", 
"midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]
    if request.headers["HTTP_USER_AGENT"]
	    agent = request.headers["HTTP_USER_AGENT"].downcase
	    mobile_browsers.each do |m|
		    return true if agent.match(m)
	    end    
    end
    return false
  end
    

  # Used to load listings to be shown
  # How the results are rendered depends on 
  # the type of request and if @to_render is set
  def load
    @title = params[:listing_type]
    @tag = params[:tag]
    @to_render ||= {:partial => "listings/listed_listings"}
    @listings = Listing.currently_open.order("created_at DESC").find_with(params, @current_user, @current_community).paginate(:per_page => 15, :page => params[:page])
    @request_path = request.fullpath
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render :partial => "listings/additional_listings"
    else
      render @to_render
    end
  end 
  
  def loadmap
    @title = params[:listing_type]
    @listings = Listing.currently_open.order("created_at DESC").find_with(params, @current_user)
    @listing_style = "map"
    @to_render ||= {:partial => "listings/listings_on_map"}
    @request_path = request.fullpath
    render  @to_render
  end

  # The following two are simple dummy implementations duplicating the
  # functionality of normal listing methods.
  def requests_on_map
    params[:listing_type] = "request"
    @to_render = {:action => :index}
    @listings = Listing.currently_open.order("created_at DESC").find_with(params, @current_user, @current_community)
    @listing_style = "map"
    load
  end

  def offers_on_map
    params[:listing_type] = "offer"
    @to_render = {:action => :index}
    @listing_style = "map"
    load
  end
  
  
  # A (stub) method for serving Listing data (with locations) as JSON through AJAX-requests.
  def serve_listing_data
    @listings = Listing.currently_open.joins(:origin_loc).group("listings.id").
                order("listings.created_at DESC").find_with(params, @current_user, @current_community).select("listings.id, listing_type, category, latitude, longitude")
    render :json => { :data => @listings }
  end
  
  def listing_bubble
    if params[:id]
      @listing = Listing.find(params[:id])
      if @listing.visible_to?(@current_user, @current_community)
        render :partial => "homepage/recent_listing", :locals => { :listing => @listing }
      else
        render :partial => "bubble_listing_not_visible"
      end
    end 
  end
  
  # Used to show multiple listings in one bubble
  def listing_bubble_multiple
    @listings = Listing.visible_to(@current_user, @current_community, params[:ids])
    if @listings.size > 0
      render :partial => "homepage/recent_listing", :collection => @listings, :as => :listing, :spacer_template => "homepage/request_spacer"
    else
      render :partial => "bubble_listing_not_visible"
    end
  end

  def show
    session[:selected_tab] = "home"
    unless current_user?(@listing.author)
      @listing.increment!(:times_viewed)
    end
  end
  
  def new
    session[:selected_tab] = "home"
    @listing = Listing.new
    @listing.listing_type = params[:type]
    @listing.category = params[:category]
    #@latitude = 13
    if @listing.category == "rideshare"
	    @listing.build_origin_loc(:location_type => "origin_loc")
	    @listing.build_destination_loc(:location_type => "destination_loc")
    else
	    if (@current_user.location != nil)
	      temp = @current_user.location
	      temp.location_type = "origin_loc"
	      @listing.build_origin_loc(temp.attributes)
      else
	      @listing.build_origin_loc(:location_type => "origin_loc")
      end
    end
    1.times { @listing.listing_images.build }
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def create
    if params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin_loc_attributes][:address].blank?
      params[:listing].delete("origin_loc_attributes")
    end
    @listing = @current_user.create_listing params[:listing]
    if @listing.new_record?
      1.times { @listing.listing_images.build } if @listing.listing_images.empty?
      render :action => :new
    else
      path = new_request_category_path(:type => @listing.listing_type, :category => @listing.category)
      flash[:notice] = ["#{@listing.listing_type}_created_successfully", "create_new_#{@listing.listing_type}".to_sym, path]
      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, request.host))
      redirect_to @listing
    end
  end
  
  def edit
    session[:selected_tab] = "home"
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
    if @listing.update_fields(params[:listing])
      @listing.location.update_attributes(params[:location]) if @listing.location
      flash[:notice] = "#{@listing.listing_type}_updated_successfully"
      Delayed::Job.enqueue(ListingUpdatedJob.new(@listing.id, request.host))
      redirect_to @listing
    else
      render :action => :edit
    end    
  end
  
  def close
    @listing.update_attribute(:open, false)
    notice = "#{@listing.listing_type}_closed"
    respond_to do |format|
      format.html { 
        flash[:notice] = notice
        redirect_to @listing 
      }
      format.js {
        flash.now[:notice] = notice
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
    unless @listing.visible_to?(@current_user, @current_community)
      if @listing.public?
        # This situation occurs when the user tries to access a listing
        # via a different community url.
        flash[:error] = "this_content_is_not_available_in_this_community"
        redirect_to root and return
      elsif @current_user
        flash[:error] = "you_are_not_authorized_to_view_this_content"
        redirect_to root and return
      else
        session[:return_to] = request.fullpath
        flash[:warning] = "you_must_log_in_to_view_this_content"
        redirect_to login_path and return
      end
    end
  end
  
  def change_follow_status(status)
    status.eql?("follow") ? @current_user.follow(@listing) : @current_user.unfollow(@listing)
    notice = "you_#{status}ed_listing"
    respond_to do |format|
      format.html { 
        flash[:notice] = notice
        redirect_to @listing 
      }
      format.js {
        flash.now[:notice] = notice
        render :follow, :layout => false 
      }
    end
  end

end
