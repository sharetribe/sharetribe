module DiscoveryUtils

  module_function

  def listing_query_params(original)
    location_params =
      if(original[:latitude].present? && original[:longitude].present?)
        { :'search[lat]' => original[:latitude],
          :'search[lng]' => original[:longitude],
          :'search[distance_unit]' => original[:distance_unit],
          :'search[scale]' => original[:scale],
          :'search[offset]' => original[:offset],
          :'filter[distance_max]' => original[:distance_max] }
      else
        {}
      end

    custom_fields = Maybe(original[:fields]).map { |fields|
      fields.select { |f| [:numeric_range, :selection_group].include?(f[:type]) }
      fields.map { |f|
        if f[:type]  == :numeric_range
          [:"custom[#{f[:id]}]", "double:#{f[:value].first}:#{f[:value].last}"]
        else
          [:"custom[#{f[:id]}]", "opt:#{f[:operator]}:#{f[:value].join(",")}"]
        end
      }.to_h
    }.or_else({})

    {
     :marketplace_id => original[:marketplace_id],
     :'search[keywords]' => original[:keywords],
     :'page[number]' => original[:page],
     :'page[size]' => original[:per_page],
     :'filter[price_min]' => Maybe(original[:price_cents]).map{ |p| p.min }.or_else(nil),
     :'filter[price_max]' => Maybe(original[:price_cents]).map{ |p| p.max }.or_else(nil),
     :'filter[omit_closed]' => !original[:include_closed],
     :'filter[listing_shape_ids]' => Maybe(original[:listing_shape_ids]).join(",").or_else(nil),
     :'filter[category_ids]' => Maybe(original[:categories]).join(",").or_else(nil),
     :'search[locale]' => original[:locale],
     :sort => original[:sort]
    }.merge(location_params).merge(custom_fields).compact
  end
end
