class ListingsController < ApplicationController

  before_filter :logged_in, :only  => [ :new, :create, :destroy ]

  def index
    save_navi_state(['listings', 'browse_listings', 'all_categories'])
    @title = :all_categories
    @pagination_type = "category"
    fetch_listings('')
  end

  def show
    if (params[:id])
      save_navi_state(['listings', 'browse_listings'])
      @listing = Listing.find(params[:id])
      @listing.update_attribute(:times_viewed, @listing.times_viewed + 1) 
      @next_listing = Listing.find(:first, :conditions => ["id > ?", @listing.id]) || @listing
      @previous_listing = Listing.find(:last, :conditions => ["id < ?", @listing.id]) || @listing
    else  
      @title = :own_listings
      save_navi_state(['own', 'own_listings'])
      fetch_listings("author_id = '" + @current_user.id.to_s + "'")
      @pagination_type = "own_listings"
      render :action => "index"
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
          conditions = params[:only_open] ? ["status = 'open' OR status = 'in_progress'"] : ["status = 'open' OR status = 'in_progress' OR status = 'closed'"]
          @listings = Listing.find_by_contents(query, {:page => params[:page], :per_page => per_page.to_i, :order => 'id DESC', :sort => s}, {:conditions => conditions})
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
      flash[:notice] = 'Ilmoitus lisätty.'
      redirect_to listings_path
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
    flash[:notice] = 'Ilmoitus poistettu.'
    redirect_to listings_path
  end

end
