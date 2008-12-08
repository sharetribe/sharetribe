class ListingsController < ApplicationController

  before_filter :logged_in, :only  => [ :new, :create, :destroy, :mark_as_interesting, :mark_as_not_interesting, :reply, :close ]

  def index
    if params[:person_id]
      @pagination_type = "person_listings" 
      @person = Person.find(params[:person_id])
      @title = :listings_partitive_plural
      conditions = "author_id = '" + @person.id.to_s + "'"
      session[:profile_navi] = 'listings'
      save_navi_state(['own', 'own_listings', '', '', 'listings']) if session[:navi1] == 'own'
      fetch_listings(conditions, "status DESC, id DESC")
      render :template => "listings/own"
    else
      @pagination_type = "category"
      @title = :all_categories
      save_navi_state(['listings', 'browse_listings', 'all_categories'])
      fetch_listings("status = 'open'")
    end    
  end

  def show
    @listing = Listing.find(params[:id])
    unless @current_user && @listing.author.id == @current_user.id
      @listing.update_attribute(:times_viewed, @listing.times_viewed + 1)
    end
    if params[:cl]
      @previous_listing = @next_listing = @listing
    else   
      next_id = session[:ids].reject {|id| id <= params[:id].to_i }.last
      @next_listing = next_id ? Listing.find(next_id) : @listing
      previous_id = session[:ids].reject {|id| id >= params[:id].to_i }.first
      @previous_listing = previous_id ? Listing.find(previous_id) : @listing
    end  
  end

  def search
    save_navi_state(['listings', 'search_listings', ''])
    if params[:type]
      if params[:q]
        # Advanced search
      end
    else
      if params[:q]
        query = params[:q]
        begin
          s = Ferret::Search::SortField.new(:id_sort, :reverse => true)
          conditions = params[:only_open] ? ["status = 'open'"] : ["status IN ('open', 'closed')"]
          listings = Listing.find_by_contents(query, {:sort => s}, {:conditions => conditions})
          save_collection_to_session(listings)
          @listings = listings.paginate :page => params[:page], :per_page => per_page
        end
      end    
    end   
  end

  def new
    save_navi_state(['listings', 'add_listing', ''])
    @listing = Listing.new
  end  

  def create
    @listing = Listing.new(params[:listing])
    language = []
    language << "fi" if (params[:listing][:language_fi].to_s.eql?('1'))
    language << "en-US" if (params[:listing][:language_en].to_s.eql?('1'))
    language << "swe" if (params[:listing][:language_swe].to_s.eql?('1'))
    @listing.language = language
    if @listing.save
      flash[:notice] = :listing_added
      redirect_to listing_path(@listing)
    else
      params[:category] = params[:listing][:category]
      Listing::MAIN_CATEGORIES.each do |main_category|
        if Listing.get_sub_categories(main_category.to_s) && Listing.get_sub_categories(main_category.to_s).include?(params[:listing][:category])
          params[:category] = main_category.to_s
          params[:subcategory] = params[:listing][:category] 
        end
      end
      render :action => "new"
    end
  end 

  def destroy
    Listing.find(params[:id]).destroy
    flash[:notice] = :listing_removed
    redirect_to listings_path
  end

  def interesting
    @title = :interesting_listings
    save_navi_state(['own', 'interesting_listings'])
    @pagination_type = "interesting_listings"
    save_collection_to_session(@current_user.interesting_listings)
    @listings = @current_user.interesting_listings.paginate :page => params[:page], 
                                 :per_page => per_page.to_i, 
                                 :order => 'id DESC'
    render :template => "listings/index"
  end

  def mark_as_interesting
    unless PersonInterestingListing.find_by_person_id_and_listing_id(@current_user.id, params[:id]) 
      @current_user.person_interesting_listings.create(:listing_id => params[:id])
    end
    redirect_to listing_path(Listing.find(params[:id]))   
  end
  
  def mark_as_not_interesting
    PersonInterestingListing.find_by_person_id_and_listing_id(@current_user.id, params[:id]).destroy
    redirect_to listing_path(Listing.find(params[:id]))
  end
  
  def reply
    @listing = Listing.find(params[:id])
    @message = Message.new
  end
  
  def close
    @listing = Listing.find(params[:id])
    @person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    if params[:rid]
      @kassi_event.realizer_id = params[:rid]
    end
    @people = Person.find(:all).collect { |p| [ p.name(session[:cookie]) + " (" + p.username(session[:cookie]) + ")", p.id ] }  
  end
  
  def mark_as_closed
    @listing = Listing.find(params[:id])
    @listing.update_attribute(:status, "closed")
    if params[:kassi_event][:realizer_id] && params[:kassi_event][:realizer_id] != ""
      create_kassi_event(@listing.category)
    end
    flash[:notice] = :listing_closed    
    redirect_to person_listings_path(@current_user)
  end

end
