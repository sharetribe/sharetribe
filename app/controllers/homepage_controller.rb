class HomepageController < ApplicationController

  before_filter :save_current_path, :except => :sign_in
  
  layout :choose_layout

  skip_filter :dashboard_only
  skip_filter :not_public_in_private_community, :only => :sign_in

  def index
    if @current_user && @current_user.member_of?(@current_community)
      @event_feed_events = @current_community.event_feed_events.limit(5).order("id DESC")
    else
      @event_feed_events = @current_community.event_feed_events.non_members_only.limit(5).order("id DESC")
    end
    listings_per_page = 15
    
    # If requesting a specific page on non-ajax request, we'll ignore that
    # and show the normal front page starting from newest listing
    params[:page] = 1 unless request.xhr? 
    
    @requests = Listing.requests.visible_to(@current_user, @current_community).currently_open.paginate(:per_page => listings_per_page, :page => params[:page])
    @offers = Listing.offers.visible_to(@current_user, @current_community).currently_open.paginate(:per_page => listings_per_page, :page => params[:page])
        
    # TODO This below should only be done if the count is actually shown, otherwise unnecessary.
    #If browsing Sharetribe unlogged, count also the number of private listings available 
    unless @current_user
      @private_listings = {}
      @private_listings["request"] = Listing.requests.currently_open.private_to_community(@current_community).count
      @private_listings["offer"] = Listing.offers.currently_open.private_to_community(@current_community).count
    end
    
    if request.xhr? # checks if AJAX request
      render :partial => "additional_listings", :locals => {:type => :request, :requests => @requests, :offers => @offers}   
    else
      if @current_community.news_enabled?
        @news_items = @current_community.news_items.order("created_at DESC").limit(2)
        @news_item_count = @current_community.news_items.count
      end  
    end
  end
  
  # This is going to get removed in the v3.0 design when there's no more separate sign_in page for private communities.
  def sign_in
    redirect_to root_path unless @current_community.private?
    @requests = @current_community.listings.requests.currently_open.limit(5)
    @total_request_count = @current_community.listings.requests.currently_open.count
    @offers = @current_community.listings.offers.currently_open.limit(5)
    @total_offer_count = @current_community.listings.offers.currently_open.count
    @container_class = "container_12"
  end
  
  private
  
  def choose_layout
    if 'sign_in'.eql? action_name
      'private'
    else
      'application'
    end
  end

end
