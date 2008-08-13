class ListingsController < ApplicationController

  def index
    save_navi_state(['listings', 'browse_listings', 'all_categories'])
    if (params[:type])
      case params[:type]
      when "all"
        @title = :all_listings
        save_navi_state(['people', 'listings', 'all'])
      when "interesting"
        @title = :interesting_listings
        save_navi_state(['people', 'listings', 'interesting'])
      when "own"
        @title = :own_listings
        save_navi_state(['people', 'listings', 'own'])
      else
      end
    elsif (params[:category])
      if (["buy", "sell", "give"].include?(params[:category]))
        save_navi_state(['listings', 'browse_listings', 'marketplace', params[:category]])
      else
        save_navi_state(['listings', 'browse_listings', params[:category], ''])
      end
      @title = params[:category]
    end  
  end

  def search
    save_navi_state(['listings', 'search_listings', ''])
  end

  def add
    save_navi_state(['listings', 'add_listing', ''])
  end

end
