class Api::ListingsController < Api::ApiController
  include ListingsHelper
  before_filter :authenticate_person!, :except => [:index, :show]
  before_filter :require_community, :except => :show
  before_filter :ensure_authorized_to_view_listing, :only => [:show]
  
  def index
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
      
    @listings = Listing.find_with(params, @current_user, @current_community, @per_page, @page)
    
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
    
    if api_version_alpha?
      # fix old style visibility setting "everybody" to new format
      if params["visibility"] == "everybody"
        params["visibility"] = "all_communities"
        params["privacy"] ||= "public"
      end
    
      # fix old style share_type
      if params["share_type"] == "trade"
        if params["listing_type"] == "offer"
          params["share_type"] = "offer_to_swap"
        else
          params["share_type"] = "request_to_swap"
        end
      end  
    end
    
    # This is moved out from the "api_version_alpha?" as new iPhone client still sent listing_type
    if params["share_type"].nil?
      params["share_type"] = params["listing_type"]
    end

    # share_type was renamed to transaction_type
    transaction_type_param = params["share_type"]
    
    category = Category.find_by_id(params["category"])

    unless category && @current_community.categories.include?(category)
      response.status = 400
      render :json => ["Given category is not available in this community."] and return
    end
    
    # Check if old client putting the listing to a top level category while there would be subcategories, and put the listing to "other" subcategory
    if category.children
      sub_category_for_misc = category.children.where(["name like ?", "other%"]).first
      category = sub_category_for_misc if sub_category_for_misc
    end
    
    transaction_type = TransactionType.find_by_id(transaction_type_param)
    unless transaction_type && @current_community.transaction_types.include?(transaction_type)
      response.status = 400
      render :json => ["Given transaction_type is not available in this community."] and return
    end
    
    @listing = Listing.new(params.slice("title", 
                                        "description",   
                                        "visibility",
                                        "privacy",
                                        "origin",
                                        "destination",
                                        "origin_loc_attributes",
                                        "valid_until",
                                        "price_cents",
                                        "currency",
                                        "quantity",
                                        "destination_loc_attributes"
                                        ).merge({"author_id" => current_person.id,
                                                 "category" => category,
                                                 "transaction_type" => transaction_type,
                                                 "listing_images_attributes" => {"0" => {"image" => params["image"]} }}))
    
    
    if current_person.member_of?(@current_community)
      @listing.communities << @current_community
    else
      response.status = 400
      render :json => ["The user is not member of given community."] and return
    end
    
    if @listing.save
      Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.id))
      response.status = 201 
      respond_with(@listing)
    else
      response.status = 400
      render :json => @listing.errors.full_messages and return
    end
    
  end

end