class MapviewController < ApplicationController

  def index
    redirect_to root
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

  def load
    @title = params[:listing_type]
    @to_render ||= {:partial => "listings/listed_listings"}
    @listings = Listing.open.order("created_at DESC").find_with(params, @current_user).paginate(:per_page => 15, :page => params[:page])
    @request_path = request.fullpath
    if request.xhr? && params[:page] && params[:page].to_i > 1
      render :partial => "listings/additional_listings"
    else
      render  @to_render
    end
  end

end
