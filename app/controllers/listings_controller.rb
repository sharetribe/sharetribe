class ListingsController < ApplicationController

  before_filter :logged_in, :only  => [ :new, :create, :destroy, :mark_as_interesting, :mark_as_not_interesting, :reply, :close ]

  caches_action :index, :cache_path => :index_cache_path.to_proc
  # use sweeper to decet changes that require cache expiration. 
  # Some non-changing methods are excluded. not sure if it helps anything for performance?
  cache_sweeper :listing_sweeper, :except => [:show, :index, :new, :search]

  def index
    if params[:person_id]
      @pagination_type = "person_listings" 
      @person = Person.find(params[:person_id])
      @title = :listings_partitive_plural
      conditions = ["author_id = ?" + get_visibility_conditions("listing"), @person.id.to_s ]
      session[:links_panel_navi] = 'listings'
      save_navi_state(['own', 'profile']) if current_user?(@person)
      fetch_listings(conditions, "status DESC, id DESC")
      render :template => "listings/own"
    else
      @pagination_type = "category"
      @title = :all_categories
      save_navi_state(['listings', 'browse_listings', 'all_categories'])
      conditions = "status = 'open' AND good_thru >= '" + Date.today.to_s + "'"
      conditions += get_visibility_conditions("listing")
      fetch_listings(conditions)
    end    
  end

  def show
    save_navi_state(['listings', 'browse_listings', 'all_categories']) unless session[:navi2] && !session[:navi2].eql?("")
    @listing = Listing.find(params[:id])
    unless is_visible?(@listing)
      flash[:error] = :no_permission_to_view_this_content
      redirect_to listings_path
    end  
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
    conditions = params[:only_open] ? ["status = 'open' AND good_thru >= ?" + get_visibility_conditions("listing"), Date.today.to_s] : ""
    if params[:q]
      if params[:category] && !params[:category][:category].eql?("")
        if params[:only_open]
          conditions = ["status = 'open' AND good_thru >= ? AND category = ?" + get_visibility_conditions("listing"), Date.today.to_s, params[:category][:category]]
        else  
          conditions = ["category = ?" + get_visibility_conditions("listing"), params[:category][:category]]
        end    
      end
      query = (params[:q].length > 0) ? "*" + params[:q] + "*" : ""
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
    get_visibility(:listing)
    @listing = Listing.new(params[:listing])
    language = []
    language << "fi" if (params[:listing][:language_fi].to_s.eql?('1'))
    language << "en" if (params[:listing][:language_en].to_s.eql?('1'))
    language << "swe" if (params[:listing][:language_swe].to_s.eql?('1'))
    @listing.language = language
    if @listing.save
      @listing.save_group_visibilities(params[:groups])
      @listing.newsgroup = params[:newsgroup]
      @listing.post_to_newsgroups(request.protocol + request.host + listing_path(@listing))
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
    @object_visibility = @listing.visibility
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
    @groups = @listing.groups
  end
  
  def update
    @listing = Listing.find(params[:id])
    language = []
    language << "fi" if (params[:listing][:language_fi].to_s.eql?('1'))
    language << "en" if (params[:listing][:language_en].to_s.eql?('1'))
    language << "swe" if (params[:listing][:language_swe].to_s.eql?('1'))
    @listing.language = language
    get_visibility(:listing)
    @listing.update_attributes(params[:listing])
    if @listing.save
      @listing.save_group_visibilities(params[:groups])
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
  
  def comments
    save_navi_state(['own', 'comments_to_own_listings'])
    @comments = ListingComment.find_by_sql("SELECT listing_comments.id, listing_comments.is_read, listing_comments.created_at, listing_comments.content, listing_comments.listing_id, listings.title, listing_comments.author_id FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = '" + @current_user.id + "' AND listing_comments.author_id <> '" + @current_user.id + "' ORDER BY listing_comments.created_at desc").paginate :page => params[:page], :per_page => per_page.to_i
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
    @kassi_event.person_comments.build  
  end
  
  def mark_as_closed
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    @listing.update_attribute(:status, "closed")
    if params[:kassi_event][:realizer_id] && params[:kassi_event][:realizer_id] != ""
      @kassi_event = KassiEvent.new(params[:kassi_event])
      if @kassi_event.save
        flash[:notice] = :listing_closed
      else
        puts @kassi.event.errors.full_messages.inspect
        @person = @listing.author
        @people = Person.find(:all, :conditions => ["id <> ?", @current_user.id]).collect { 
          |p| [ p.name(session[:cookie]) + " (" + p.username(session[:cookie]) + ")", p.id ] 
        }
        render :action => :close and return
      end
    end
    redirect_to params[:return_to]
  end
  
  #shows a random listing (that is visible to all)
  def random
    conditions = "status = 'open' AND good_thru >= '" + Date.today.to_s + "'"
    conditions += get_visibility_conditions("listing")
        
    open_listings_ids = Listing.all(:select => "id, title", :conditions => conditions)
    random_id = open_listings_ids[Kernel.rand(open_listings_ids.length)]
    redirect_to listing_path(random_id)
  end
  
  # Displays a form for feedback for listing realizer when closing the form
  def realizer_feedback_form
    if params[:realizer] && params[:realizer] != ""
      @realizer = Person.find(params[:realizer])
      @listing = Listing.find(params[:listing])  
    end
    render :partial => "realizer_feedback_form"
  end
  
  private
  
  def index_cache_path
    if @current_user
      "listings_list/#{session[:locale]}/#{listings_last_changed}/#{@current_user.id}"
    else
       "listings_list/#{session[:locale]}/#{listings_last_changed}/non-registered"
    end
  end
  
  def is_visible?(listing)
    conditions = get_visibility_conditions("listing")
    conditions.slice!(0..3)
    Listing.find(:all, :conditions => conditions).include?(listing)
  end

end
