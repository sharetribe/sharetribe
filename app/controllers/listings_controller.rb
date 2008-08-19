class ListingsController < ApplicationController

  def index
    save_navi_state(['listings', 'browse_listings', 'all_categories'])
    if (params[:type])
      case params[:type]
      when "all"
        @title = :all_listings
        save_navi_state(['own', 'listings', 'all'])
        fetch_listings('')
      when "interesting"
        @title = :interesting_listings
        save_navi_state(['own', 'listings', 'interesting'])
        fetch_listings('')
      when "own"
        @title = :own_listings
        save_navi_state(['own', 'listings', 'own_listings_navi'])
        fetch_listings("author_id = '" + session[:person_id].to_s + "'")
      else
      end
    elsif (params[:category])
      if (["buy", "sell", "give"].include?(params[:category]))
        save_navi_state(['listings', 'browse_listings', 'marketplace', params[:category]])
      else
        save_navi_state(['listings', 'browse_listings', params[:category], ''])
      end
      @title = params[:category]
      if (params[:category].eql?("all_categories"))
        fetch_listings('')
      elsif (params[:category].eql?("marketplace"))
        fetch_listings("category = 'sell' OR category = 'buy' OR category = 'give'")
      else  
        fetch_listings("category = '" + params[:category] + "'")
      end
    else
      save_navi_state(['listings', 'browse_listings', 'all_categories'])
      @title = :all_listings
      fetch_listings('')   
    end
  end

  def show
    save_navi_state(['listings', 'browse_listings'])
    @listing = Listing.find(params[:id])
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
    if @listing.save
      flash[:notice] = 'Ilmoitus lisätty.'
      redirect_to listings_path
    else
      render :action => "new"
    end
  end

  def fetch_listings(conditions)
    @listings = Listing.find :all,
        :order => 'created_at DESC',
        :conditions => conditions
  end

end
