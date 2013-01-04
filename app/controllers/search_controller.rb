class SearchController < ApplicationController
  
  skip_filter :dashboard_only
  
  def show
    @query = params[:q]
    if @query
      with = {:open => true}
      if params[:type]
        with[:is_request] = true if params[:type].eql?("request")
        with[:is_offer] = true if params[:type].eql?("offer")
      end
      unless @current_user && @current_user.communities.include?(@current_community)
        with[:visible_to_everybody] = true
      end
      with[:community_ids] = @current_community.id

      @listings = Listing.search(@query, 
                                :include => :listing_images, 
                                :page => params[:page],
                                :per_page => 15, 
                                :star => true,
                                :with => with
                                )
      
      if request.xhr? # checks if AJAX request
        render :partial => "listings/additional_listings" 
      end
      
    end
    
    
  end

end
