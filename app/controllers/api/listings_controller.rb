class Api::ListingsController < Api::ApiController

  before_filter :authenticate_person!, :except => [:index, :show]
  
  def index
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
    
    query = params.slice("category", "listing_type")
    
    if params["status"] == "closed"
      query["open"] = false
    elsif params["status"] == "all"
      # leave "open" out totally to return all statuses
    else
      query["open"] = true #default
    end
    
    if params["community_id"]
      @listings = Community.find(params["community_id"]).listings.where(query).order("created_at DESC").paginate(:per_page => @per_page, :page => @page)
    else
      @listings = Listing.where(query).order("created_at DESC").paginate(:per_page => @per_page, :page => @page)
    end
    respond_with @listings
  end

  def show
    @listing = Listing.find(params[:id])
    respond_with @listing
  end

  def create
    @listing = Listing.new(params.slice("title", "description", "category", "share_type", "listing_type", "visibility").merge({"author_id" => current_person.id, "listing_images_attributes" => {"0" => {"image" => params["image"]} }}))
    
    @community = Community.find(params["community_id"])
    if @community.nil?
      response.status = 400
      render :json => ["community_id parameter missing, or no community found with given id"] and return
    end
    
    if current_person.member_of?(@community)
      @listing.communities << @community
    else
      response.status = 400
      render :json => ["The user is not member of given community."] and return
    end
    
    if @listing.save
      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @community.full_domain))
      response.status = 201 
      respond_with(@listing)
    else
      response.status = 400
      render :json => @listing.errors.full_messages and return
    end
    
  end

end