class SearchController < ApplicationController

  def show
    @query = params[:q]
    if @query
      #query = (params[:q].length > 0) ? "*#{params[:q]}*" : ""
      #person_query = (params[:q].length > 0) ? params[:q] : ""
      
      with = {:open => true}
      if params[:type]
        with[:is_request] = true if params[:type].eql?("request")
        with[:is_offer] = true if params[:type].eql?("offer")
      end
      if @current_user 
        with[:visible_to_everybody] = true
      else
        with[:visible_to_kassi_users] = true
      end    

      @listings = Listing.search(@query, 
                                :include => :listing_images, 
                                :page => params[:page],
                                :per_page => 15, 
                                :star => true,
                                :with => with
                                )
      
      # FIXME: Here performance could be boosted if the contents of the resluting JSON would be used
      # and not only the IDs picked from there, and used to request person details separately.
      # ids = Array.new
      # Person.search(person_query)["entry"].each do |person|
      #   ids << person["id"]
      # end
      # @people = Person.find_kassi_users_by_ids(ids)
      # @person_amount = @people.size
      
      if request.xhr? # checks if AJAX request
        render :partial => "listings/additional_listings" 
      end
      
    end
    
    
  end

end
