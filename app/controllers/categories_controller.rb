class CategoriesController < ApplicationController

  def show
    save_navi_state(['listings', 'browse_listings', params[:id], ''])
    Listing::MAIN_CATEGORIES.each do |main_category|
      if Listing.get_sub_categories(main_category.to_s) && Listing.get_sub_categories(main_category.to_s).include?(params[:id])
        save_navi_state(['listings', 'browse_listings', main_category, params[:id]]) 
      end
    end
    @title = params[:id]
    if (params[:id].eql?("all_categories"))
      fetch_listings('')
    elsif (params[:id].eql?("marketplace"))
      fetch_listings("category = 'sell' OR category = 'buy' OR category = 'give'")
    else  
      fetch_listings("category = '" + params[:id] + "'")
    end
    render :template => "listings/index"
  end

end
