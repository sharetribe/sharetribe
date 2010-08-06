class HomepageController < ApplicationController

  before_filter :save_current_path

  def index
    @events = ["Event 1", "Event 2", "Event 3"]
    @requests = Listing.requests.order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    @offers = Listing.offers.order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    
    if request.xhr? # checks if AJAX request
      render :partial => "additional_listings", :locals => {:type => :request, :requests => @requests, :offers => @offers}   
    end
  end

end
