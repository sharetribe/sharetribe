class Api::ListingsController < Api::ApiController

  before_filter :authenticate_person!, :except => [:index, :show]
  
  def index
    query = params.slice("category", "listing_type")
    #query["listing_type"] = params["type"] if params["type"]
    
    if params["status"] == "closed"
      query["open"] = false
    elsif params["status"] == "all"
      # leave "open" out totally to return all statuses
    else
      query["open"] = true #default
    end
    
    
    if params["community_id"]
      @listings = Community.find(params["community_id"]).listings.where(query)
    else
      @listings = Listing.where(query)
    end
    respond_with @listings
  end

  def show
    @listing = Listing.find(params[:id])
    respond_with @listing
  end

  def create
    @listing = Listing.create(params.slice("title", "description", "category", "share_type", "listing_type", "visibility").merge("author_id" => current_person.id))
    
    @community = Community.find(params["community_id"])
    if @community.nil?
      response.status = 400
      render :json => ["community_id parameter missing, or no community found with given id"]
    end
    
    if current_person.member_of?(@community)
      @listing.communities << @community
    else
      response.status = 400
      render :json => ["The user is not member of given community."]
    end
    
    if @listing.new_record?
      response.status = 400
      render :json => @listing.errors.full_messages
    else
      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, "#{@community.domain}.#{APP_CONFIG.weekly_email_domain}"))
      response.status = 201 
      respond_with(@listing)
    end
    
  end

end