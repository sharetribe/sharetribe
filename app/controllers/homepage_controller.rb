class HomepageController < ApplicationController

  before_filter :save_current_path, :except => :sign_in
  
  layout :choose_layout

  skip_filter :dashboard_only
  skip_filter :not_public_in_private_community, :only => :sign_in

  def index
    listings_per_page = 10
    
    # If requesting a specific page on non-ajax request, we'll ignore that
    # and show the normal front page starting from newest listing
    params[:page] = 1 unless request.xhr? 
    @query = params[:q]
    
    if @query # Search used
      with = {:open => true}
      unless @current_user && @current_user.communities.include?(@current_community)
        with[:visible_to_everybody] = true
      end
      with[:community_ids] = @current_community.id

      @listings = Listing.search(@query, 
                                :include => :listing_images, 
                                :page => params[:page],
                                :per_page => listings_per_page, 
                                :star => true,
                                :with => with
                                )
      
    else # no search used

      @listings = Listing.visible_to(@current_user, @current_community).currently_open.order("created_at DESC").paginate(:per_page => listings_per_page, :page => params[:page])
    end
    
    if request.xhr? # checks if AJAX request
      render :partial => "recent_listing", :collection => @listings, :as => :listing   
    else
      if @current_community.news_enabled?
        @news_items = @current_community.news_items.order("created_at DESC").limit(2)
        @news_item_count = @current_community.news_items.count
      end  
    end
  end
  
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
