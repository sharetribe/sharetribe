class Api::ListingsController < Api::ApiController
  include ListingsHelper
  before_filter :authenticate_person!, :except => [:index, :show]
  before_filter :require_community, :except => :show
  before_filter :ensure_authorized_to_view_listing, :only => [:show]
  
  def index
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
    
    # listing type is old param, but if it's defined and share_type is not, we use that as share_type
    params["share_type"] = params["share_type"] || params["listing_type"] 
    
    query = {}
    joined_tables = []
    
    if params["cateogry"]
      cateogry = Category.find_by_name(params["cateogry"])
      if cateogry
        query[:cateogries] = {:id => cateogry.with_all_children.collect(&:id)} 
        joined_tables << :cateogry
      else
       response.status = :bad_request
       render :json => ["Category '#{params["cateogry"]}' not found."] and return
      end
    end
    
    if params["share_type"]   
      share_type = ShareType.find_by_name(params["share_type"])
      if share_type
        query[:share_types] = {:id => share_type.with_all_children.collect(&:id)}
        joined_tables << :share_type
      else
        response.status = :bad_request
        render :json => ["Share type '#{params["share_type"]}' not found."] and return
      end
    end
    
    if params["status"] == "closed"
      query["open"] = false
    elsif params["status"] == "all"
      # leave "open" out totally to return all statuses
    else
      query["open"] = true #default
    end
    
    if params["person_id"]
      query["author_id"] = params["person_id"]
    end
    
    unless @current_user && @current_user.communities.include?(@current_community)
      query["privacy"] = "public"
    end
    
    if params["search"]
      @listings = search_listings(params["search"], query)
    elsif @current_community
      listings_to_query = (query["open"] ? @current_community.listings.currently_open : @current_community.listings)
      @listings = listings_to_query.joins(joined_tables).where(query).order("created_at DESC").paginate(:per_page => @per_page, :page => @page)
    else
      # This is actually not currently supported. Community_id is currently required parameter.
      @listings = Listing.where(query).order("created_at DESC").paginate(:per_page => @per_page, :page => @page)
    end
    
    @total_pages = @listings.total_pages
    
    # Few extra fields for ATOM feed
    if params[:format].to_s == "atom" 
      
      @category_label = (params["category"] ? "(" + localized_category_label(params["category"]) + ")" : "")
      
      if ["request","offer"].include?params['share_type']
        listing_type_label = t("listings.index.#{params['share_type']+"s"}")
      else
         listing_type_label = t("listings.index.listings")
      end
      
      @title = t("listings.index.feed_title", :optional_category => @category_label, :community_name => @current_community.name_with_separator(I18n.locale), :listing_type => listing_type_label)
      @updated = @listings.first.present? ? @listings.first.updated_at : Time.now
    end
    respond_with @listings
  end

  def show
    @listing = Listing.find_by_id(params[:id])
    if @listing.nil?
      response.status = 404
      render :json => ["No listing found with given ID"] and return
    end
    respond_with @listing
  end

  def create
    # Set locations correctly if provided in params
    if params["latitude"] || params["address"]
      params.merge!({"origin_loc_attributes" => {"latitude" => params["latitude"], 
                                                 "longitude" => params["longitude"], 
                                                 "address" => params["address"], 
                                                 "google_address" => params["address"], 
                                                 "location_type" => "origin_loc"}})
      
      if params["destination_latitude"] || params["destination_address"]
        params.merge!({"destination_loc_attributes" => {"latitude" => params["destination_latitude"], 
                                                        "longitude" => params["destination_longitude"], 
                                                        "address" => params["destination_address"], 
                                                        "google_address" => params["destination_address"], 
                                                        "location_type" => "destination_loc"}})
      end
    end
    
    # fix old style visibility setting "everybody" to new format
    if params["visibility"] == "everybody"
      params["visibility"] = "all_communities"
      params["privacy"] ||= "public"
    end
    
    category = Category.find_by_name(params["category"])

    unless category && @current_community.categories.include?(category)
      response.status = 400
      render :json => ["Given category is not available in this community."] and return
    end
    
    share_type = ShareType.find_by_name(params["share_type"])
    unless share_type && @current_community.share_types.include?(share_type)
      response.status = 400
      render :json => ["Given share_type is not available in this community."] and return
    end
    
    @listing = Listing.new(params.slice("title", 
                                        "description",   
                                        "visibility",
                                        "privacy",
                                        "origin",
                                        "destination",
                                        "origin_loc_attributes",
                                        "valid_until",
                                        "destination_loc_attributes"
                                        ).merge({"author_id" => current_person.id,
                                                 "category" => category,
                                                 "share_type" => share_type,
                                                 "listing_images_attributes" => {"0" => {"image" => params["image"]} }}))
    
    
    if current_person.member_of?(@current_community)
      @listing.communities << @current_community
    else
      response.status = 400
      render :json => ["The user is not member of given community."] and return
    end
    
    if @listing.save
      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.full_domain))
      response.status = 201 
      respond_with(@listing)
    else
      response.status = 400
      render :json => @listing.errors.full_messages and return
    end
    
  end
  
  def search_listings(search, attributes)
    with = {}
    
    unless attributes["open"].nil?
      with[:open] = true if attributes["open"] == true
      with[:open] = false if attributes["open"] == false
    end
    
    if attributes["share_type"]
      with[:is_request] = true if attributes["share_type"].eql?("request")
      with[:is_offer] = true if attributes["share_type"].eql?("offer")
    end
    
    
    
    unless @current_user && @current_user.communities.include?(@current_community)
      with[:visible_to_everybody] = true
    end
    
    # Here is expected that @current_community always exists as community_id is currently required parameter
    with[:community_ids] = @current_community.id

    Listing.search(search, :include => :listing_images, 
                           :page => @page,
                           :per_page => @per_page, 
                           :star => true,
                           :with => with
                           )
  end

end