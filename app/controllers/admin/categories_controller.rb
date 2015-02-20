class Admin::CategoriesController < ApplicationController

  before_filter :ensure_is_admin

  def index
    @selected_left_navi_link = "listing_categories"
    @categories = @current_community.top_level_categories.includes(:children)
  end

  def new
    @selected_left_navi_link = "listing_categories"
    @category = Category.new
    @default_listing_shapes = Maybe(@current_community.categories.last).listing_shapes.or_else { [] }
  end

  def create
    @selected_left_navi_link = "listing_categories"
    @category = Category.new(listing_shape_params_to_transaction_type(params[:category]))
    @category.community = @current_community
    @category.parent_id = nil if params[:category][:parent_id].blank?
    @category.sort_priority = Admin::SortingService.next_sort_priority(@current_community.categories)
    logger.info "Translations #{@category.translations.inspect}"
    @default_listing_shapes = Maybe(@current_community.categories.last).listing_shapes.or_else { [] }
    if @category.save
      redirect_to admin_categories_path
    else
      flash[:error] = "Category saving failed"
      render :action => :new
    end
  end

  def edit
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @default_listing_shapes = @category.listing_shapes
  end

  def update
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @default_listing_shapes = @category.listing_shapes
    if @category.update_attributes(listing_shape_params_to_transaction_type(params[:category]))
      redirect_to admin_categories_path
    else
      flash[:error] = "Category saving failed"
      render :action => :edit
    end
  end

  def order
    sort_priorities = params[:order].each_with_index.map do |category_id, index|
      [category_id, index]
    end.inject({}) do |hash, ids|
      category_id, sort_priority = ids
      hash.merge(category_id.to_i => sort_priority)
    end

    @current_community.categories.select do |category|
      sort_priorities.has_key?(category.id)
    end.each do |category|
      category.update_attributes(:sort_priority => sort_priorities[category.id])
    end

    render nothing: true, status: 200
  end

  # Remove form
  def remove
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @possible_merge_targets = Admin::CategoryService.merge_targets_for(@current_community.categories, @category)
  end

  # Remove action
  def destroy
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @category.destroy
    redirect_to admin_categories_path
  end

  def destroy_and_move
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    new_category = @current_community.categories.find_by_url_or_id(params[:new_category])

    if new_category
      # Move listings
      @category.own_and_subcategory_listings.update_all(:category_id => new_category.id)

      # Move custom fields
      Admin::CategoryService.move_custom_fields!(@category, new_category)
    end

    @category.destroy

    redirect_to admin_categories_path
  end

  # This is only temporary
  def listing_shape_params_to_transaction_type(params)
    listing_shape_ids = params[:listing_shape_attributes].map { |ls| ls[:listing_shape_id] }
    transaction_type_ids = listing_shape_ids.map { |lsid|
      @current_community.listing_shapes.where(id: lsid).first.transaction_type_id
    }

    transaction_type_attributes = transaction_type_ids.map { |ttid|
      {transaction_type_id: ttid}
    }

    params.merge({transaction_type_attributes: transaction_type_attributes})

  end

end
