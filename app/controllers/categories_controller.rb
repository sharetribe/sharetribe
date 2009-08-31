class CategoriesController < ApplicationController

  before_filter :update_navi, :only => [ :show] #needed for cached actions
  caches_action :show, :layout => false, :cache_path => Proc.new { |c| "category_list/#{c.params[:id]}/#{c.session[:locale]}/#{CacheHelper.listings_last_changed}/p#{c.params[:page]}/pp#{c.params[:per_page]}/#{c.session[:person_id]}"}
  
  cache_sweeper :listing_sweeper

  def update_navi
    save_navi_state(['listings', 'browse_listings', params[:id], ''])
    Listing::MAIN_CATEGORIES.each do |main_category|
      if Listing.get_sub_categories(main_category.to_s) && Listing.get_sub_categories(main_category.to_s).include?(params[:id])
        save_navi_state(['listings', 'browse_listings', main_category, params[:id]]) 
      end
    end
  end


  def show

    # part of the code moved to filter
    
    sub_categories = Listing.get_sub_categories(params[:id].to_s)
    conditions = sub_categories ? sub_categories.collect {|subcategory| "category = '" + subcategory + "'" }.join(" OR ") : nil 
    
    # part of the code moved to filter
    
    @title = params[:id]
    default_conditions = "status = 'open' AND good_thru >= '" + Date.today.to_s + "'"
    default_conditions += get_visibility_conditions("listing")
    if (params[:id].eql?("all_categories"))
      fetch_listings(default_conditions)
    elsif (conditions)
      fetch_listings(default_conditions + " AND (" + conditions + ")")
    else  
      fetch_listings("category = '" + params[:id] + "'" + " AND " + default_conditions)
    end
    @pagination_type = "category"
    render :template => "listings/index"
  end

end
