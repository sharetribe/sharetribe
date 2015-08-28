# encoding: utf-8
class HomepageController < ApplicationController

  before_filter :save_current_path, :except => :sign_in

  APP_DEFAULT_VIEW_TYPE = "grid"
  VIEW_TYPES = ["grid", "list", "map"]

  ListingItem = Struct.new(
    :id,
    :title,
    :category_id,
    :latitude,
    :longitude,
    :author,
    :description,
    :listing_images,
    :price,
    :unit_tr_key,
    :unit_type,
    :quantity,
    :shape_name_tr_key,
    :listing_shape_id,
    :icon_name)

  Author = Struct.new(
    :id,
    :username,
    :first_name,
    :last_name,
    :avatar,
    :is_deleted,
    :num_of_reviews)

  Price = Struct.new(
    :price_cents,
    :currency)

  ListingImage = Struct.new(
    :thumb,
    :small_3x2)

  def index
    @homepage = true

    @view_type = HomepageController.selected_view_type(params[:view], @current_community.default_browse_view, APP_DEFAULT_VIEW_TYPE, VIEW_TYPES)

    @categories = @current_community.categories.includes(:children)
    @main_categories = @categories.select { |c| c.parent_id == nil }

    all_shapes = shapes.get(community_id: @current_community.id)[:data]

    # This assumes that we don't never ever have communities with only 1 main share type and
    # only 1 sub share type, as that would make the listing type menu visible and it would look bit silly
    listing_shape_menu_enabled = all_shapes.size > 1
    @show_categories = @categories.size > 1
    show_price_filter = @current_community.show_price_filter && all_shapes.any? { |s| s[:price_enabled] }
    @show_custom_fields = @current_community.custom_fields.any?(&:can_filter?) || show_price_filter
    @category_menu_enabled = @show_categories || @show_custom_fields

    @app_store_badge_filename = "/assets/Available_on_the_App_Store_Badge_en_135x40.svg"
    if File.exists?("app/assets/images/Available_on_the_App_Store_Badge_#{I18n.locale}_135x40.svg")
       @app_store_badge_filename = "/assets/Available_on_the_App_Store_Badge_#{I18n.locale}_135x40.svg"
    end

    filter_params = {}

    listing_shape_param = params[:transaction_type]

    all_shapes = shapes.get(community_id: @current_community.id)[:data]
    selected_shape = all_shapes.find { |s| s[:name] == listing_shape_param }

    filter_params[:listing_shape] = Maybe(selected_shape)[:id].or_else(nil)

    compact_filter_params = HashUtils.compact(filter_params)

    per_page = @view_type == "map" ? APP_CONFIG.map_listings_limit : APP_CONFIG.grid_listings_limit

    search_result = find_listings(params, per_page, compact_filter_params)

    shape_name_map = all_shapes.map { |s| [s[:id], s[:name]]}.to_h

    if request.xhr? # checks if AJAX request
      search_result.on_success { |listings|
        @listings = listings # TODO Remove

        if @view_type == "grid" then
          render :partial => "grid_item", :collection => @listings, :as => :listing
        else
          render :partial => "list_item", :collection => @listings, :as => :listing, locals: { shape_name_map: shape_name_map, testimonials_in_use: @current_community.testimonials_in_use }
        end
      }.on_error {
        render nothing: true, status: 500
      }
    else
      search_result.on_success { |listings|
        @listings = listings
        render locals: {
                 shapes: all_shapes,
                 show_price_filter: show_price_filter,
                 selected_shape: selected_shape,
                 shape_name_map: shape_name_map,
                 testimonials_in_use: @current_community.testimonials_in_use,
                 listing_shape_menu_enabled: listing_shape_menu_enabled }
      }.on_error { |e|
        flash[:error] = "An error occured. Please translate me!"
        @listings = Listing.none.paginate(:per_page => 1, :page => 1)
        render status: 500, locals: {
                 shapes: all_shapes,
                 show_price_filter: show_price_filter,
                 selected_shape: selected_shape,
                 shape_name_map: shape_name_map,
                 testimonials_in_use: @current_community.testimonials_in_use,
                 listing_shape_menu_enabled: listing_shape_menu_enabled }
      }
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

  def find_listings(params, listings_per_page, filter_params)
    Maybe(@current_community.categories.find_by_url_or_id(params[:category])).each do |category|
      filter_params[:category] = category.id
      @selected_category = category
    end

    filter_params[:search] = params[:q] if params[:q]
    filter_params[:custom_dropdown_field_options] = HomepageController.dropdown_field_options_for_search(params)
    filter_params[:custom_checkbox_field_options] = HomepageController.checkbox_field_options_for_search(params)

    filter_params[:price_cents] = filter_range(params[:price_min], params[:price_max])

    p = HomepageController.numeric_filter_params(params)
    p = HomepageController.parse_numeric_filter_params(p)
    p = HomepageController.group_to_ranges(p)
    numeric_search_params = HomepageController.filter_unnecessary(p, @current_community.custom_numeric_fields)

    numeric_search_needed = !numeric_search_params.empty?

    filter_params[:listing_ids] = if numeric_search_needed
      NumericFieldValue.search_many(numeric_search_params).collect(&:listing_id)
    end

    filter_params = filter_params.reject {
      |_, value| (value == "all" || value == ["all"])
    } # all means the filter doesn't need to be included

    if numeric_search_needed && filter_params[:listing_ids].empty?
      Listing.none.paginate(:per_page => listings_per_page, :page => params[:page])
    else
      checkboxes = {
        search_type: :and,
        values: filter_params[:custom_checkbox_field_options] || []
      }

      dropdowns = {
        search_type: :or,
        values: filter_params[:custom_dropdown_field_options] || []
      }
      search = {
        # Add listing_id
        category_id: filter_params[:category],
        listing_shape_id: Maybe(filter_params)[:listing_shapes][:id].or_else(nil),
        price_cents: filter_params[:price_cents],
        keywords: filter_params[:search],
        checkboxes: checkboxes,
        dropdowns: dropdowns,
        per_page: listings_per_page,
        page: params[:page] || 1,
        listing_ids: filter_params[:listing_ids]
      }

      ListingService::API::Api.listings.search(community_id: @current_community.id, search: search).and_then { |res|
        listings = res.map { |l|
          ListingItem.new(
            l[:id],
            l[:title],
            l[:category_id],
            l[:latitude],
            l[:longitude],
            Author.new(
              l[:author][:id],
              l[:author][:username],
              l[:author][:first_name],
              l[:author][:last_name],
              ListingImage.new(
                l[:author][:avatar][:thumb]
              ),
              l[:author][:is_deleted],
              l[:author][:num_of_reviews],
            ),
            l[:description],
            l[:listing_images].map { |li|
              ListingImage.new(li[:thumb], li[:small_3x2]) },
            l[:price],
            l[:unit_tr_key],
            l[:unit_type],
            l[:quantity],
            l[:shape_name_tr_key],
            l[:listing_shape_id],
            l[:icon_name]
          )
        }

        paginated = WillPaginate::Collection.create(params[:page] || 1, listings_per_page, listings.count) do |pager|
          pager.replace(listings)
        end

        Result::Success.new(paginated)
      }
    end
  end

  def filter_range(price_min, price_max)
    if (price_min && price_max)
      min = MoneyUtil.parse_str_to_money(price_min, @current_community.default_currency).cents
      max = MoneyUtil.parse_str_to_money(price_max, @current_community.default_currency).cents

      if ((@current_community.price_filter_min..@current_community.price_filter_max) != (min..max))
        (min..max)
      else
        nil
      end
    end
  end

  def to_struct(struct_class, hash)
    args = struct_class.members.map { |k| hash[k] }
    struct_class.new(*args)
  end

  # Return all params starting with `numeric_filter_`
  def self.numeric_filter_params(all_params)
    all_params.select { |key, value| key.start_with?("nf_") }
  end

  def self.parse_numeric_filter_params(numeric_params)
    numeric_params.inject([]) do |memo, numeric_param|
      key, value = numeric_param
      _, boundary, id = key.split("_")

      hash = {id: id.to_i}
      hash[boundary.to_sym] = value
      memo << hash
    end
  end

  def self.group_to_ranges(parsed_params)
    parsed_params
      .group_by { |param| param[:id] }
      .map do |key, values|
        boundaries = values.inject(:merge)

        {
          custom_field_id: key,
          numeric_value: (boundaries[:min].to_f..boundaries[:max].to_f)
        }
      end
  end

  # Filter search params if their values equal min/max
  def self.filter_unnecessary(search_params, numeric_fields)
    search_params.reject do |search_param|
      numeric_field = numeric_fields.find(search_param[:custom_field_id])
      search_param == { custom_field_id: numeric_field.id, numeric_value: (numeric_field.min..numeric_field.max) }
    end
  end

  def self.options_from_params(params, regexp)
    option_ids = HashUtils.select_by_key_regexp(params, regexp).values

    array_for_search = CustomFieldOption.find(option_ids)
      .group_by { |option| option.custom_field_id }
      .map { |key, selected_options| selected_options.collect(&:id) }
  end

  def self.dropdown_field_options_for_search(params)
    options_from_params(params, /^filter_option/)
  end

  def self.checkbox_field_options_for_search(params)
    options_from_params(params, /^checkbox_filter_option/)
  end

  def shapes
    ListingService::API::Api.shapes
  end
end
