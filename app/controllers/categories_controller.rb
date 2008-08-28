class CategoriesController < ApplicationController

  def show
    save_navi_state(['listings', 'browse_listings', params[:id], ''])
    sub_categories = Listing.get_sub_categories(params[:id].to_s)
    conditions = sub_categories ? sub_categories.collect {|subcategory| "category = '" + subcategory + "'" }.join(" OR ") : nil 
    Listing::MAIN_CATEGORIES.each do |main_category|
      if Listing.get_sub_categories(main_category.to_s) && Listing.get_sub_categories(main_category.to_s).include?(params[:id])
        save_navi_state(['listings', 'browse_listings', main_category, params[:id]]) 
      end
    end
    @title = params[:id]
    if (params[:id].eql?("all_categories"))
      fetch_listings('')
    elsif (conditions)
      fetch_listings(conditions)
    else  
      fetch_listings("category = '" + params[:id] + "'")
    end
    render :template => "listings/index"
  end

end
