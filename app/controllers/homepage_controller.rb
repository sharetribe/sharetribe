# encoding: utf-8
class HomepageController < ApplicationController

  before_filter :save_current_path, :except => :sign_in

  APP_DEFAULT_VIEW_TYPE = "grid"
  VIEW_TYPES = ["grid", "list", "map"]
  APP_MINIMUM_DISTANCE_MAX = 5


  def index
    redirect_to landing_page_path and return if no_current_user_in_private_clp_enabled_marketplace?

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

    filters = @current_community.custom_fields.where(search_filter: true).sort
    @show_custom_fields = filters.present? || show_price_filter
    @category_menu_enabled = @show_categories || @show_custom_fields

    filter_params = {}

    listing_shape_param = params[:transaction_type]

    selected_shape = all_shapes.find { |s| s[:name] == listing_shape_param }

    filter_params[:listing_shape] = Maybe(selected_shape)[:id].or_else(nil)

    compact_filter_params = HashUtils.compact(filter_params)

    per_page = @view_type == "map" ? APP_CONFIG.map_listings_limit : APP_CONFIG.grid_listings_limit

    includes =
      case @view_type
      when "grid"
        [:author, :listing_images]
      when "list"
        [:author, :listing_images, :num_of_reviews]
      when "map"
        [:location]
      else
        raise ArgumentError.new("Unknown view_type #{@view_type}")
      end

    main_search = location_search_available ? MarketplaceService::API::Api.configurations.get(community_id: @current_community.id).data[:main_search] : :keyword
    location_search_in_use = main_search == :location

    search_result = find_listings(params, per_page, compact_filter_params, includes.to_set, location_search_in_use)

    shape_name_map = all_shapes.map { |s| [s[:id], s[:name]]}.to_h

    if @view_type == 'map'
      coords = Maybe(params[:boundingbox]).split(',').or_else(nil)
      viewport = if coords
        sw_lat, sw_lng, ne_lat, ne_lng = coords
        { boundingbox: { sw: [sw_lat, sw_lng], ne: [ne_lat, ne_lng] } }
      elsif params[:lc].present?
        { center: params[:lc].split(',') }
      else
        Maybe(@current_community.location)
          .map { |l| { center: [l.latitude, l.longitude] }}
          .or_else(nil)
      end
    end

    if request.xhr? # checks if AJAX request
      search_result.on_success { |listings|
        @listings = listings # TODO Remove

        if @view_type == "grid" then
          render partial: "grid_item", collection: @listings, as: :listing, locals: { show_distance: location_search_in_use }
        elsif location_search_in_use
          render partial: "list_item_with_distance", collection: @listings, as: :listing, locals: { shape_name_map: shape_name_map, testimonials_in_use: @current_community.testimonials_in_use, show_distance: location_search_in_use }
        else
          render partial: "list_item", collection: @listings, as: :listing, locals: { shape_name_map: shape_name_map, testimonials_in_use: @current_community.testimonials_in_use }
        end
      }.on_error {
        render nothing: true, status: 500
      }
    else
      search_result.on_success { |listings|
        @listings = listings
        render locals: {
                 shapes: all_shapes,
                 filters: filters,
                 show_price_filter: show_price_filter,
                 selected_shape: selected_shape,
                 shape_name_map: shape_name_map,
                 testimonials_in_use: @current_community.testimonials_in_use,
                 listing_shape_menu_enabled: listing_shape_menu_enabled,
                 main_search: main_search,
                 location_search_in_use: location_search_in_use,
                 viewport: viewport }
      }.on_error { |e|
        flash[:error] = t("homepage.errors.search_engine_not_responding")
        @listings = Listing.none.paginate(:per_page => 1, :page => 1)
        render status: 500, locals: {
                 shapes: all_shapes,
                 filters: filters,
                 show_price_filter: show_price_filter,
                 selected_shape: selected_shape,
                 shape_name_map: shape_name_map,
                 testimonials_in_use: @current_community.testimonials_in_use,
                 listing_shape_menu_enabled: listing_shape_menu_enabled,
                 main_search: main_search,
                 location_search_in_use: location_search_in_use,
                 viewport: viewport }
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

  def find_listings(params, listings_per_page, filter_params, includes, location_search_in_use)
    Maybe(@current_community.categories.find_by_url_or_id(params[:category])).each do |category|
      filter_params[:categories] = category.own_and_subcategory_ids
      @selected_category = category
    end

    filter_params[:search] = params[:q] if params[:q] && !location_search_in_use
    filter_params[:custom_dropdown_field_options] = HomepageController.dropdown_field_options_for_search(params)
    filter_params[:custom_checkbox_field_options] = HomepageController.checkbox_field_options_for_search(params)

    filter_params[:price_cents] = filter_range(params[:price_min], params[:price_max])

    p = HomepageController.numeric_filter_params(params)
    p = HomepageController.parse_numeric_filter_params(p)
    p = HomepageController.group_to_ranges(p)
    numeric_search_params = HomepageController.filter_unnecessary(p, @current_community.custom_numeric_fields)

    filter_params = filter_params.reject {
      |_, value| (value == "all" || value == ["all"])
    } # all means the filter doesn't need to be included

    checkboxes = filter_params[:custom_checkbox_field_options].map { |checkbox_field| checkbox_field.merge(type: :selection_group, operator: :and) }
    dropdowns = filter_params[:custom_dropdown_field_options].map { |dropdown_field| dropdown_field.merge(type: :selection_group, operator: :or) }
    numbers = numeric_search_params.map { |numeric| numeric.merge(type: :numeric_range) }

    distance_unit = (location_search_in_use && MarketplaceService::API::Api.configurations.get(community_id: @current_community.id).data[:distance_unit] == :metric) ? :km : :miles
    location_search_hash = location_search_params(
      params[:lc],
      distance_unit,
      params[:distance_max],
      APP_MINIMUM_DISTANCE_MAX
    )
    search_extra = location_search_hash.blank? ? { sort: nil } : location_search_hash

    search = {
      # Add listing_id
      categories: filter_params[:categories],
      listing_shape_ids: Array(filter_params[:listing_shape]),
      price_cents: filter_params[:price_cents],
      keywords: filter_params[:search],
      fields: checkboxes.concat(dropdowns).concat(numbers),
      per_page: listings_per_page,
      page: Maybe(params)[:page].to_i.map { |n| n > 0 ? n : 1 }.or_else(1),
      price_min: params[:price_min],
      price_max: params[:price_max],
      locale: I18n.locale,
      include_closed: false
    }.merge(search_extra)

    raise_errors = Rails.env.development?

    ListingIndexService::API::Api.listings.search(
      community_id: @current_community.id,
      search: search,
      includes: includes,
      engine: search_engine,
      raise_errors: raise_errors
      ).and_then { |res|
      Result::Success.new(
        ListingIndexViewUtils.to_struct(
        result: res,
        includes: includes,
        page: search[:page],
        per_page: search[:per_page]
      ))
    }
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
          id: key,
          value: (boundaries[:min].to_f..boundaries[:max].to_f)
        }
      end
  end

  # Filter search params if their values equal min/max
  def self.filter_unnecessary(search_params, numeric_fields)
    search_params.reject do |search_param|
      numeric_field = numeric_fields.find(search_param[:id])
      search_param == { id: numeric_field.id, value: (numeric_field.min..numeric_field.max) }
    end
  end

  def self.options_from_params(params, regexp)
    option_ids = HashUtils.select_by_key_regexp(params, regexp).values

    array_for_search = CustomFieldOption.find(option_ids)
      .group_by { |option| option.custom_field_id }
      .map { |key, selected_options| {id: key, value: selected_options.collect(&:id) } }
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

  def search_coordinates(latlng)
    lat, lng = latlng.split(',')
    if(lat.present? && lng.present?)
      return { latitude: lat, longitude: lng }
    else
      ArgumentError.new("Format of latlng coordinate pair \"#{latlng}\" wasn't \"lat,lng\" ")
    end
  end

  def location_search_params(latlng, distance_unit, distance_max, minimum_distance_max)
    # Current map doesn't react to zoom & panning, so we fetch all the results as before.
    if @view_type != 'map'
      Maybe(latlng)
        .map {
          search_coordinates(latlng).merge({
            distance_unit: distance_unit,
            distance_max: [minimum_distance_max, distance_max.to_f].max,
            sort: :distance
          })
        }
        .or_else({})
    else
      {}
    end
  end

  def no_current_user_in_private_clp_enabled_marketplace?
    CustomLandingPage::LandingPageStore.enabled?(@current_community.id) &&
      @current_community.private &&
      !@current_user
  end

end
