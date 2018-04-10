# encoding: utf-8
class HomepageController < ApplicationController

  before_action :save_current_path, :except => :sign_in

  APP_DEFAULT_VIEW_TYPE = "grid"
  VIEW_TYPES = ["grid", "list", "map"]

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  def index
    params = unsafe_params_hash.select{|k, v| v.present? }

    redirect_to landing_page_path and return if no_current_user_in_private_clp_enabled_marketplace?

    all_shapes = @current_community.shapes
    shape_name_map = all_shapes.map { |s| [s[:id], s[:name]]}.to_h

    filter_params = {}

    m_selected_category = Maybe(@current_community.categories.find_by_url_or_id(params[:category]))
    filter_params[:categories] = m_selected_category.own_and_subcategory_ids.or_nil
    selected_category = m_selected_category.or_nil
    relevant_filters = select_relevant_filters(m_selected_category.own_and_subcategory_ids.or_nil)

    if FeatureFlagHelper.feature_enabled?(:searchpage_v1)
      @view_type = "grid"
    else
      @view_type = SearchPageHelper.selected_view_type(params[:view], @current_community.default_browse_view, APP_DEFAULT_VIEW_TYPE, VIEW_TYPES)
      @big_cover_photo = !(@current_user || CustomLandingPage::LandingPageStore.enabled?(@current_community.id)) || params[:big_cover_photo]

      @categories = @current_community.categories.includes(:children)
      @main_categories = @categories.select { |c| c.parent_id == nil }

      # This assumes that we don't never ever have communities with only 1 main share type and
      # only 1 sub share type, as that would make the listing type menu visible and it would look bit silly
      listing_shape_menu_enabled = all_shapes.size > 1
      @show_categories = @categories.size > 1
      show_price_filter = @current_community.show_price_filter && all_shapes.any? { |s| s[:price_enabled] }

      @show_custom_fields = relevant_filters.present? || show_price_filter
      @category_menu_enabled = @show_categories || @show_custom_fields
    end

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

    main_search = search_mode
    enabled_search_modes = search_modes_in_use(params[:q], params[:lc], main_search)
    keyword_in_use = enabled_search_modes[:keyword]
    location_in_use = enabled_search_modes[:location]

    current_page = Maybe(params)[:page].to_i.map { |n| n > 0 ? n : 1 }.or_else(1)
    relevant_search_fields = parse_relevant_search_fields(params, relevant_filters)

    search_result = find_listings(params: params,
                                  current_page: current_page,
                                  listings_per_page: per_page,
                                  filter_params: compact_filter_params,
                                  includes: includes.to_set,
                                  location_search_in_use: location_in_use,
                                  keyword_search_in_use: keyword_in_use,
                                  relevant_search_fields: relevant_search_fields)

    if @view_type == 'map'
      viewport = viewport_geometry(params[:boundingbox], params[:lc], @current_community.location)
    end

    if FeatureFlagHelper.feature_enabled?(:searchpage_v1)
      search_result.on_success { |listings|
        render layout: "layouts/react_page.haml", template: "search_page/search_page", locals: { props: searchpage_props(listings, current_page, per_page) }
      }.on_error {
        flash[:error] = t("homepage.errors.search_engine_not_responding")
        render layout: "layouts/react_page.haml", template: "search_page/search_page", locals: { props: searchpage_props(nil, current_page, per_page) }
      }
    elsif request.xhr? # checks if AJAX request
      search_result.on_success { |listings|
        @listings = listings # TODO Remove

        if @view_type == "grid" then
          render partial: "grid_item", collection: @listings, as: :listing, locals: { show_distance: location_in_use }
        elsif location_in_use
          render partial: "list_item_with_distance", collection: @listings, as: :listing, locals: { shape_name_map: shape_name_map, show_distance: location_in_use }
        else
          render partial: "list_item", collection: @listings, as: :listing, locals: { shape_name_map: shape_name_map }
        end
      }.on_error {
        render body: nil, status: 500
      }
    else
      locals = {
        shapes: all_shapes,
        filters: relevant_filters,
        show_price_filter: show_price_filter,
        selected_category: selected_category,
        selected_shape: selected_shape,
        shape_name_map: shape_name_map,
        listing_shape_menu_enabled: listing_shape_menu_enabled,
        main_search: main_search,
        location_search_in_use: location_in_use,
        current_page: current_page,
        current_search_path_without_page: search_path(params.except(:page)),
        viewport: viewport,
        search_params: CustomFieldSearchParams.remove_irrelevant_search_params(params, relevant_search_fields),
      }

      search_result.on_success { |listings|
        @listings = listings
        render locals: locals.merge(
                 seo_pagination_links: seo_pagination_links(params, @listings.current_page, @listings.total_pages))
      }.on_error { |e|
        flash[:error] = t("homepage.errors.search_engine_not_responding")
        @listings = Listing.none.paginate(:per_page => 1, :page => 1)
        render status: 500,
               locals: locals.merge(
                 seo_pagination_links: seo_pagination_links(params, @listings.current_page, @listings.total_pages))
      }
    end
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength

  private

  def parse_relevant_search_fields(params, relevant_filters)
    search_filters = SearchPageHelper.parse_filters_from_params(params)
    checkboxes = search_filters[:checkboxes]
    dropdowns = search_filters[:dropdowns]
    numbers = filter_unnecessary(search_filters[:numeric], @current_community.custom_numeric_fields)
    search_fields = checkboxes.concat(dropdowns).concat(numbers)

    SearchPageHelper.remove_irrelevant_search_fields(search_fields, relevant_filters)
  end

  def find_listings(params:, current_page:, listings_per_page:, filter_params:, includes:, location_search_in_use:, keyword_search_in_use:, relevant_search_fields:)

    search = {
      # Add listing_id
      categories: filter_params[:categories],
      listing_shape_ids: Array(filter_params[:listing_shape]),
      price_cents: filter_range(params[:price_min], params[:price_max]),
      keywords: keyword_search_in_use ? params[:q] : nil,
      fields: relevant_search_fields,
      per_page: listings_per_page,
      page: current_page,
      price_min: params[:price_min],
      price_max: params[:price_max],
      locale: I18n.locale,
      include_closed: false,
      sort: nil
    }

    if @view_type != 'map' && location_search_in_use
      search.merge!(location_search_params(params, keyword_search_in_use))
    end

    raise_errors = Rails.env.development?

    if FeatureFlagHelper.feature_enabled?(:searchpage_v1)
      DiscoveryClient.get(:query_listings,
                          params: DiscoveryUtils.listing_query_params(search.merge(marketplace_id: @current_community.id)))
      .rescue {
        Result::Error.new(nil, code: :discovery_api_error)
      }
        .and_then{ |res|
        Result::Success.new(res[:body])
      }
    else
      ListingIndexService::API::Api.listings.search(
        community_id: @current_community.id,
        search: search,
        includes: includes,
        engine: FeatureFlagHelper.search_engine,
        raise_errors: raise_errors
        ).and_then { |res|
        Result::Success.new(
          ListingIndexViewUtils.to_struct(
            result: res,
            includes: includes,
            page: search[:page],
            per_page: search[:per_page]
          )
        )
      }
    end
  end

  def location_search_params(params, keyword_search_in_use)
    marketplace_configuration = @current_community.configuration

    distance = params[:distance_max].to_f
    distance_system = marketplace_configuration ? marketplace_configuration[:distance_unit].to_sym : nil
    distance_unit = distance_system == :metric ? :km : :miles
    limit_search_distance = marketplace_configuration ? marketplace_configuration[:limit_search_distance] : true
    distance_limit = [distance, APP_CONFIG[:external_search_distance_limit_min].to_f].max if limit_search_distance

    corners = params[:boundingbox].split(',') if params[:boundingbox].present?
    center_point = if limit_search_distance && corners&.length == 4
      LocationUtils.center(*corners.map { |n| LocationUtils.to_radians(n) })
    else
      search_coordinates(params[:lc])
    end

    scale_multiplier = APP_CONFIG[:external_search_scale_multiplier].to_f
    offset_multiplier = APP_CONFIG[:external_search_offset_multiplier].to_f
    combined_search_in_use = keyword_search_in_use && scale_multiplier && offset_multiplier
    combined_search_params = if combined_search_in_use
      {
        scale: [distance * scale_multiplier, APP_CONFIG[:external_search_scale_min].to_f].max,
        offset: [distance * offset_multiplier, APP_CONFIG[:external_search_offset_min].to_f].max
      }
    else
      {}
    end

    sort = :distance unless combined_search_in_use

    {
      distance_unit: distance_unit,
      distance_max: distance_limit,
      sort: sort
    }
    .merge(center_point)
    .merge(combined_search_params)
    .compact
  end

  # Filter search params if their values equal min/max
  def filter_unnecessary(search_params, numeric_fields)
    search_params.reject do |search_param|
      numeric_field = numeric_fields.find(search_param[:id])
      search_param.slice(:id, :value) == { id: numeric_field.id, value: (numeric_field.min..numeric_field.max) }
    end
  end

  def filter_range(price_min, price_max)
    if (price_min && price_max)
      min = MoneyUtil.parse_str_to_money(price_min, @current_community.currency).cents
      max = MoneyUtil.parse_str_to_money(price_max, @current_community.currency).cents

      if ((@current_community.price_filter_min..@current_community.price_filter_max) != (min..max))
        (min..max)
      else
        nil
      end
    end
  end

  def search_coordinates(latlng)
    lat, lng = latlng.split(',')
    if(lat.present? && lng.present?)
      return { latitude: lat, longitude: lng }
    else
      ArgumentError.new("Format of latlng coordinate pair \"#{latlng}\" wasn't \"lat,lng\" ")
    end
  end

  def no_current_user_in_private_clp_enabled_marketplace?
    CustomLandingPage::LandingPageStore.enabled?(@current_community.id) &&
      @current_community.private &&
      !@current_user
  end

  def search_modes_in_use(q, lc, main_search)
    # lc should be two decimal coordinates separated with a comma
    # e.g. 65.123,-10
    coords_valid = /^-?\d+(?:\.\d+)?,-?\d+(?:\.\d+)?$/.match(lc)
    {
      keyword: q && (main_search == :keyword || main_search == :keyword_and_location),
      location: coords_valid && (main_search == :location || main_search == :keyword_and_location),
    }
  end

  def viewport_geometry(boundingbox, lc, community_location)
    coords = Maybe(boundingbox).split(',').or_else(nil)
    if coords
      sw_lat, sw_lng, ne_lat, ne_lng = coords
      { boundingbox: { sw: [sw_lat, sw_lng], ne: [ne_lat, ne_lng] } }
    elsif lc.present?
      { center: lc.split(',') }
    else
      Maybe(community_location)
        .map { |l| { center: [l.latitude, l.longitude] }}
        .or_else(nil)
    end
  end

  def seo_pagination_links(params, current_page, total_pages)
    prev_page =
      if current_page > 1
        search_path(params.merge(page: current_page - 1))
      end

    next_page =
      if current_page < total_pages
        search_path(params.merge(page: current_page + 1))
      end

    {
      prev: prev_page,
      next: next_page
    }
  end

  def searchpage_props(bootstrapped_data, page, per_page)
    SearchPageHelper.searchpage_props(
      page: page,
      per_page: per_page,
      bootstrapped_data: bootstrapped_data,
      notifications_to_react: notifications_to_react,
      display_branding_info: display_branding_info?,
      community: @current_community,
      path_after_locale_change: @return_to,
      user: @current_user,
      search_placeholder: @community_customization&.search_placeholder,
      current_path: request.fullpath,
      locale_param: params[:locale],
      host_with_port: request.host_with_port)
  end

  # Database select for "relevant" filters based on the `category_ids`
  #
  # If `category_ids` is present, returns only filter that belong to
  # one of the given categories. Otherwise returns all filters.
  #
  def select_relevant_filters(category_ids)
    relevant_filters =
      if category_ids.present?
        @current_community
          .custom_fields
          .joins(:category_custom_fields)
          .where("category_custom_fields.category_id": category_ids, search_filter: true)
          .distinct
      else
        @current_community
          .custom_fields.where(search_filter: true)
      end

    relevant_filters.sort
  end

  def unsafe_params_hash
    params.to_unsafe_hash
  end

end
