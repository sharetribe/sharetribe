class HomepageController < ApplicationController

  before_filter :save_current_path

  def index
    @events = ["Event 1", "Event 2", "Event 3"]
    #@requests = ["Kyyti HKI-Turku", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore", "ATK-apu"]
    @requests = Listing.requests.order("created_at desc").paginate(:per_page => 2, :page => params[:page])
    @offers = Listing.offers.order("created_at desc").paginate(:per_page => 2, :page => params[:page])

    
    if request.xhr?
      
      #render :partial => "recent_listing", :collection => @requests, :as => :listing, :spacer_template => "request_spacer"
      #render :partial => @requests
      render :partial => "additional_listings", :locals => {:type => :request, :listings => @requests}
      
    end

  end

end
