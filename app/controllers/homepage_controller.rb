class HomepageController < ApplicationController

  before_filter :save_current_path

  def index
    @events = ["Event 1", "Event 2", "Event 3"]
    listings_per_page = 15
      
    unless session[:welcome_message]
      flash.now[:info_message] = ["welcome_message", :read_more, about_infos_path]
      session[:welcome_message] = true    
    end  
    
    # If requesting a specific page on non-ajax request, we'll ignore that
    # and show the normal front page starting from newest listing
    params[:page] = 1 unless request.xhr?
    
    @requests = Listing.requests.open.paginate(:per_page => listings_per_page, :page => params[:page])
    @offers = Listing.offers.open.paginate(:per_page => listings_per_page, :page => params[:page])
    
    if request.xhr? # checks if AJAX request
      render :partial => "additional_listings", :locals => {:type => :request, :requests => @requests, :offers => @offers}   
    end
  end

end
