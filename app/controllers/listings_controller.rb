class ListingsController < ApplicationController

  before_filter :save_current_path, :only => :show

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_create_new_#{params[:type]}"
  end
  
  before_filter :only => :close do |controller|
    controller.ensure_authorized "only_listing_author_can_close_a_listing"
  end
  
  def requests
    params[:listing_type] = "request"
    @to_render = {:action => :index}
    load
  end
  
  def offers
    params[:listing_type] = "offer"
    @to_render = {:action => :index}
    load
  end
  
  # Used to load listings to be shown
  # How the results are rendered depends on 
  # the type of request and if @to_render is set
  def load
    @title = params[:listing_type]
    @to_render ||= {:partial => "listings/listed_listings"}
    @listings = Listing.open.find_with(params).paginate(:per_page => 15, :page => params[:page])
    @request_path = request.fullpath
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render :partial => "listings/additional_listings"
    else
      render  @to_render
    end
  end
  
  def show
    @listing = Listing.find(params[:id])
  end
  
  def new
    @listing = Listing.new
    @listing.listing_type = params[:type]
    @listing.category = params[:category] || "item"
    1.times { @listing.listing_images.build }
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def create
    @listing = @current_user.create_listing params[:listing]
    if @listing.new_record?
      1.times { @listing.listing_images.build } if @listing.listing_images.empty?
      render :action => :new
    else
      path = new_request_category_path(:type => @listing.listing_type, :category => @listing.category)
      flash[:notice] = ["#{@listing.listing_type}_created_successfully", "create_new_#{@listing.listing_type}".to_sym, path]
      redirect_to @listing
    end
  end
  
  def edit
    @listing = Listing.find(params[:id])
    1.times { @listing.listing_images.build } if @listing.listing_images.empty?
  end
  
  def update
    @listing = Listing.find(params[:id])
    if @listing.update_fields(params[:listing])
      flash[:notice] = "#{@listing.listing_type}_updated_successfully"
      redirect_to @listing
    else
      render :action => :edit
    end    
  end
  
  def close
    @listing = Listing.find(params[:id])
    @listing.update_attribute(:open, false)
    flash.now[:notice] = "#{@listing.listing_type}_closed"
    respond_to do |format|
      format.html { redirect_to @listing }
      format.js { render :layout => false }
    end
  end

end
