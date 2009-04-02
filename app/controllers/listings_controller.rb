class ListingsController < ApplicationController

  before_filter :logged_in, :only  => [ :new, :create, :destroy, :mark_as_interesting, :mark_as_not_interesting, :reply, :close ]

  def index
    if params[:person_id]
      @pagination_type = "person_listings" 
      @person = Person.find(params[:person_id])
      @title = :listings_partitive_plural
      conditions = ["author_id = ?", @person.id.to_s ]
      session[:profile_navi] = 'listings'
      save_navi_state(['own', 'own_listings']) if current_user?(@person)
      fetch_listings(conditions, "status DESC, id DESC")
      render :template => "listings/own"
    else
      @pagination_type = "category"
      @title = :all_categories
      save_navi_state(['listings', 'browse_listings', 'all_categories'])
      fetch_listings("status = 'open' AND good_thru >= '" + Date.today.to_s + "'")
    end    
  end

  def show
    @listing = Listing.find(params[:id])
    if @current_user && @listing.author.id == @current_user.id
      @listing.comments.each do |comment|
        comment.update_attribute(:is_read, 1)
      end  
    else  
      @listing.update_attribute(:times_viewed, @listing.times_viewed + 1)
    end
  end

  def search
    save_navi_state(['listings', 'search_listings', ''])
    conditions = params[:only_open] ? ["status = 'open' AND good_thru >= '" + Date.today.to_s + "'"] : ""
    if params[:q]
      if params[:category] && !params[:category][:category].eql?("")
        if params[:only_open]
          conditions = ["status = 'open' AND good_thru >= ? AND category = ?", Date.today.to_s, params[:category][:category]]
        else  
          conditions = ["category = ?", params[:category][:category]]
        end    
      end
      query = params[:q]
      begin
        s = Ferret::Search::SortField.new(:id_sort, :reverse => true)
        listings = Listing.find_by_contents(query, {:sort => s}, {:conditions => conditions})
        @listings = listings.paginate :page => params[:page], :per_page => per_page
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

  def edit
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)  
    
    @language_fi = 0
    @language_swe = 0
    @language_en = 0
     
    @listing.language.each do |i|
      if i.eql?("fi")
       @language_fi = 1
      elsif i.eql?("swe")
        @language_swe = 1
      else
        @language_en = 1
      end
    end
  end
  
  def update
    @listing = Listing.find(params[:id])
    language = []
    language << "fi" if (params[:listing][:language_fi].to_s.eql?('1'))
    language << "en-US" if (params[:listing][:language_en].to_s.eql?('1'))
    language << "swe" if (params[:listing][:language_swe].to_s.eql?('1'))
    @listing.language = language
    @listing.update_attributes(params[:listing])
    if @listing.save
      flash[:notice] = :listing_updated
      redirect_to listing_path(@listing)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    @listing.destroy
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
  
  def comments
    save_navi_state(['own', 'comments_to_own_listings'])
    @comments = ListingComment.find_by_sql("SELECT listing_comments.id, listing_comments.is_read, listing_comments.created_at, listing_comments.content, listing_comments.listing_id, listings.title, listing_comments.author_id FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = '" + @current_user.id + "' AND listing_comments.author_id <> '" + @current_user.id + "' ORDER BY listing_comments.created_at desc").paginate :page => params[:page], :per_page => per_page.to_i
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
    return unless must_not_be_current_user(@listing.author, :cant_reply_to_own_listing)
    @message = Message.new
  end
  
  def close
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    @person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    if params[:rid]
      @kassi_event.realizer_id = params[:rid]
    end
    @people = Person.find(:all, :conditions => ["id <> ?", @current_user.id]).collect { 
      |p| [ p.name(session[:cookie]) + " (" + p.username(session[:cookie]) + ")", p.id ] 
    }  
  end
  
  def mark_as_closed
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    @listing.update_attribute(:status, "closed")
    if params[:kassi_event][:realizer_id] && params[:kassi_event][:realizer_id] != ""
      create_kassi_event(@listing.category)
    end
    flash[:notice] = :listing_closed    
    redirect_to person_listings_path(@current_user)
  end

end
