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
    fetch
  end
  
  def offers
    params[:listing_type] = "offer"
    fetch
  end
  
  def load
    @title = params[:listing_type]
    @listings = Listing.find_with(params).paginate(:per_page => 15, :page => params[:page])
    render :partial => "listings/listed_listings"
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
  
  private
  
  def fetch
    @title = params[:listing_type]
    @listings = Listing.find_with(params).paginate(:per_page => 15, :page => params[:page])
    request.xhr? ? (render :partial => "listings/additional_listings") : (render :action => :index)
  end

end
