class ListingsController < ApplicationController

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_create_new_#{params[:type]}"
  end
  
  def show
    @listing = Listing.find(params[:id])
  end
  
  def new
    @listing = Listing.new
  end
  
  def create
    @listing = @current_user.create_listing params[:listing]
    if @listing.new_record?
      render :action => :new
    else
      flash[:notice] = "#{@listing.listing_type}_created_successfully"
      redirect_to @listing
    end
  end

  def items
  end

  def favors
  end

end
