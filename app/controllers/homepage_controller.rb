class HomepageController < ApplicationController

  before_filter :save_current_path, :except => :sign_in

  skip_filter :dashboard_only

  APP_DEFAULT_VIEW_TYPE = "grid"
  VIEW_TYPES = ["grid", "list", "map"]

  def index
    ## Support old /?map=true URL START
    ## This can be removed after March 2014
    if !params[:view] && params[:map] == "true" then
      redirect_params = params.except(:map).merge({view: "map"})
      redirect_to url_for(redirect_params), status: :moved_permanently
    end
    ## Support old /?map=true URL END

    @homepage = true
    
    @view_type = HomepageController.selected_view_type(params[:view], @current_community.default_browse_view, APP_DEFAULT_VIEW_TYPE, VIEW_TYPES)
    
    listings_per_page = 24
    
    #Load community categories
    @categories =  Rails.cache.fetch("/community/#{@current_community.id}_#{@current_community.updated_at}/categories") {
      @current_community.categories
    } 
    
    @main_categories =  Rails.cache.fetch("/community/#{@current_community.id}_#{@current_community.updated_at}/main_categories") {
      @current_community.main_categories
    }
    @share_types = Rails.cache.fetch("/community/#{@current_community.id}_#{@current_community.updated_at}/share_types") {
      @current_community.share_types
    }
    @listing_types = Rails.cache.fetch("/community/#{@current_community.id}_#{@current_community.updated_at}/listing_types") {
      @current_community.listing_types
    }
    
    # This assumes that we don't never ever have communities with only 1 main share type and
    # only 1 sub share type, as that would make the listing type menu visible and it would look bit silly
    @listing_type_menu_enabled = @share_types.size > 1
    @show_categories = @current_community.categories.size > 1
    @show_custom_fields = @current_community.custom_fields.size > 0
    @category_menu_enabled = @show_categories || @show_custom_fields
    
    @filter_params = params.slice("category", "share_type")
    
    # If no Share Type specified, use listing_type if that is specified.
    # both are chosen in one dropdown
    @filter_params["share_type"] ||= @filter_params["listing_type"]
    @filter_params.delete("listing_type")
    
    @listing_count = @current_community.listings.currently_open.count
    unless @current_user
      @private_listing_count = Listing.currently_open.private_to_community(@current_community).count
    end
    
    @filter_params[:search] = params[:q] if params[:q]
    @filter_params[:include] = [:listing_images, :author, :category, :share_type]
    @filter_params[:custom_field_options] = HomepageController.custom_field_options_for_search(params)
      
    @listings = Listing.find_with(@filter_params, @current_user, @current_community, listings_per_page, params[:page])

    @app_store_badge_filename = "/assets/Available_on_the_App_Store_Badge_en_135x40.svg"    
    if File.exists?("app/assets/images/Available_on_the_App_Store_Badge_#{I18n.locale}_135x40.svg")
       @app_store_badge_filename = "/assets/Available_on_the_App_Store_Badge_#{I18n.locale}_135x40.svg"
    end
    
    if request.xhr? # checks if AJAX request
      if @view_type == "grid" then
        render :partial => "grid_item", :collection => @listings, :as => :listing
      else
        render :partial => "list_item", :collection => @listings, :as => :listing
      end
    else
      if @current_community.news_enabled?
        @news_items = @current_community.news_items.order("created_at DESC").limit(2)
        @news_item_count = @current_community.news_items.count
      end  
    end
  end

  def self.selected_view_type(view_param, community_default, app_default, all_types)
    if view_param.present? and all_types.include?(view_param)
      view_param
    elsif community_default.present? and all_types.include?(community_default)
      community_default
    else
      app_default
    end
  end
  
  private
  
  # Extract correct type of array from query parameters
  def self.custom_field_options_for_search(params)
    option_ids = []
    option_hash = {}
    array_for_search = []
    
    params.each do |key, value|
      if key.to_s.match(/^filter_option/)
        option_ids << value
      end  
    end
    
    custom_field_options = CustomFieldOption.find(option_ids)
    custom_field_options.each do |cfo|
      option_hash[cfo.custom_field_id] ||= []
      option_hash[cfo.custom_field_id] << cfo.id
    end
    
    option_hash.each do |key, value|
      array_for_search << value
    end
    
    array_for_search
  end
  
end
