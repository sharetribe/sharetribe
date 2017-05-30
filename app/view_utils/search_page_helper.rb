module SearchPageHelper

  module_function

  def searchpage_props(page:, per_page:, bootstrapped_data:, notifications_to_react:, display_branding_info:,
                  community:, path_after_locale_change:, user: nil, search_placeholder: nil,
                  locale_param: nil, current_path: nil, landing_page: false, host_with_port:)

    {
      i18n: {
        locale: I18n.locale,
        defaultLocale: I18n.default_locale,
        localeInfo: I18nHelper.locale_info(Sharetribe::AVAILABLE_LOCALES, I18n.locale)
      },
      marketplace: {
        marketplace_color1: CommonStylesHelper.marketplace_colors(community)[:marketplace_color1],
        location: current_path, # request.fullpath,
        notifications: notifications_to_react,
        displayBrandingInfo: display_branding_info,
        linkToSharetribe: "https://www.sharetribe.com/?utm_source=#{community.ident}.sharetribe.com&utm_medium=referral&utm_campaign=nowl-footer"
      },
      searchPage: {
        page: page,
        per_page: per_page,
        data: bootstrapped_data
      },
      topbar: TopbarHelper.topbar_props({
        community: community,
        path_after_locale_change: path_after_locale_change,
        user: user,
        search_placeholder: search_placeholder,
        locale_param: locale_param,
        current_path: current_path,
        landing_page: landing_page,
        host_with_port: host_with_port,
        }),
    }
  end

  # Warning!
  # Even though it may seem that this function is pure and free from side-effects,
  # it's actually not. The `dropdown_field_options_for_search` and
  # `checkbox_field_options_for_search` functions are making database queries.
  def parse_filters_from_params(params)
    {
      dropdowns: dropdown_field_options_for_search(params),
      checkboxes: checkbox_field_options_for_search(params),
      numeric: numeric_field_options_for_search(params),
    }.reject { |_, value|
      # all means the filter doesn't need to be included
      value == "all" || value == ["all"]
    }
  end

  def numeric_field_options_for_search(params)
    p = numeric_filter_params(params)
    p = parse_numeric_filter_params(p)
    p = group_to_ranges(p)
    p.map { |numeric| numeric.merge(type: :numeric_range) }
  end

  # Return all params starting with `numeric_filter_`
  def numeric_filter_params(all_params)
    all_params.select { |key, value| key.start_with?(CustomFieldSearchParams::NUMERIC_PREFIX) }
  end

  def parse_numeric_filter_params(numeric_params)
    numeric_params.to_h.inject([]) do |memo, numeric_param|
      key, value = numeric_param
      _, boundary, id = key.split("_")

      hash = {id: id.to_i}
      hash[boundary.to_sym] = value
      memo << hash
    end
  end

  def group_to_ranges(parsed_params)
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

  def options_from_params(params, prefix)
    option_ids = params.select { |key, value|
      key.start_with?(prefix)
    }.values

    array_for_search = CustomFieldOption.find(option_ids)
      .group_by { |option| option.custom_field_id }
      .map { |key, selected_options| {id: key, value: selected_options.collect(&:id) } }
  end

  def dropdown_field_options_for_search(params)
    options_from_params(params, CustomFieldSearchParams::DROPDOWN_PREFIX).map { |dropdown|
      dropdown.merge(
        type: :selection_group,
        operator: :or
      )
    }
  end

  def checkbox_field_options_for_search(params)
    options_from_params(params, CustomFieldSearchParams::CHECKBOX_PREFIX).map { |checkbox|
      checkbox.merge(
        type: :selection_group,
        operator: :and
      )
    }
  end

  def selected_view_type(view_param, community_default, app_default, all_types)
    if view_param.present? and all_types.include?(view_param)
      view_param
    elsif community_default.present? and all_types.include?(community_default)
      community_default
    else
      app_default
    end
  end

  def remove_irrelevant_search_fields(fields, relevant_filters)
    relevant_filter_ids = relevant_filters.map(&:id).to_set

    fields.select { |field|
      relevant_filter_ids.include?(field[:id])
    }
  end
end
