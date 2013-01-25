class HomepageController < ApplicationController

  before_filter :save_current_path, :except => :sign_in

  skip_filter :dashboard_only

  def index
    @selected_tribe_navi_tab = "home"
    listings_per_page = 10
    
    # If requesting a specific page on non-ajax request, we'll ignore that
    # and show the normal front page starting from newest listing
    params[:page] = 1 unless request.xhr? 
    
    @filter_params = params.slice("category", "share_type")
    
    # Check if share_type param contains a value that is actually a listing type
    # both are chosen in one dropdown
    if Listing::VALID_TYPES.include?(@filter_params["share_type"])
      @filter_params["listing_type"] = @filter_params["share_type"]
      @filter_params.delete("share_type")
    end
    
    unless @current_user
      @listing_count = @current_community.listings.currently_open.count
      @private_listing_count = Listing.currently_open.private_to_community(@current_community).count
    end
    
    @filter_params[:search] = params[:q] if params[:q]
    @filter_params[:include] = [:listing_images, :author]
      
    @listings = Listing.find_with(@filter_params, @current_user, @current_community, listings_per_page, params[:page])
   
    
    if request.xhr? # checks if AJAX request
      render :partial => "recent_listing", :collection => @listings, :as => :listing   
    else
      if @current_community.news_enabled?
        @news_items = @current_community.news_items.order("created_at DESC").limit(2)
        @news_item_count = @current_community.news_items.count
      end  
    end
  end
end
