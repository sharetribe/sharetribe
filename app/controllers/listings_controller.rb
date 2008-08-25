class ListingsController < ApplicationController

  def index
    save_navi_state(['listings', 'browse_listings', 'all_categories'])
    @title = :all_categories
    fetch_listings('')
  end

  def all
    @title = :all_listings
    save_navi_state(['own', 'listings', 'all'])
    fetch_listings('')
    render :action => "index"
  end

  def interesting
    @title = :interesting_listings
    save_navi_state(['own', 'listings', 'interesting'])
    fetch_listings('')
    render :action => "index"
  end
  
  def own
    @title = :own_listings
    save_navi_state(['own', 'listings', 'own_listings_navi'])
    fetch_listings("author_id = '" + session[:person_id].to_s + "'")
    render :action => "index"
  end  

  def show
    save_navi_state(['listings', 'browse_listings'])
    @listing = Listing.find(params[:id])
    @listing.times_viewed += 1 
    @listing.save
    @next_listing = Listing.find(:first, :conditions => ["created_at > ?", @listing.created_at]) || @listing
    @previous_listing = Listing.find(:last, :conditions => ["created_at < ?", @listing.created_at]) || @listing
  end

  def search
    save_navi_state(['listings', 'search_listings', ''])
  end

  def new_category
    save_navi_state(['listings', 'add_listing', ''])
  end

  def new
    save_navi_state(['listings', 'add_listing', ''])
    @listing = Listing.new
  end  

  def create
    @listing = Listing.new(params[:listing])
    language = []
    if (params[:listing][:language_fi].to_s.eql?('1'))
      language << "fi"
    end  
    if (params[:listing][:language_en].to_s.eql?('1'))
      language << "en-US"
    end
    if (params[:listing][:language_swe].to_s.eql?('1'))
      language << "swe"
    end
    # date_array = params[:listing][:good_thru].split(".")
    # date_string = date_array[2] + "-" + date_array[1] + "-" + date_array[0]
    # @listing.good_thru = date_string
    @listing.language = language
    if @listing.save
      flash[:notice] = 'Ilmoitus lisätty.'
      redirect_to listings_path
    else
      # TODO: Do this better, now doesn't work when new categories are added.
      if (["buy", "sell", "give"].include?(params[:listing][:category]))
        params[:category] = "marketplace"
        params[:subcategory] = params[:listing][:category]
      else
        params[:category] = params[:listing][:category]
      end
      render :action => "new"
    end
  end 

  def edit_create_parameters(params)

  end  

end
