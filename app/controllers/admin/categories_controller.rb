class Admin::CategoriesController < ApplicationController
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only

  def index
    @selected_left_navi_link = "listing_categories"
    @categories = @current_community.top_level_categories.includes(:children)
  end
  
  def new
    @selected_left_navi_link = "listing_categories"
    @category = Category.new
  end

  def create
    @selected_left_navi_link = "listing_categories"
    @category = Category.new(params[:category])
    @category.community = @current_community
    @category.parent_id = nil if params[:category][:parent_id].blank?
    logger.info "Translations #{@category.translations.inspect}"
    if @category.save
      redirect_to admin_categories_path
    else
      logger.info "Errors: #{@category.errors.full_messages.inspect}"
      flash[:error] = "Category saving failed"
      render :action => :new
    end
  end

end