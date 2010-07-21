class ListingsController < ApplicationController
    
  before_filter :save_current_path, :except => [ :new, :create ]  
  
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
      redirect_to @listing
    end
  end

  def items
  end

  def favors
  end

end
