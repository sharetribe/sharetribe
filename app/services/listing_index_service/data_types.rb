module ListingIndexService::DataTypes
  NumericRange = EntityUtils.define_builder(
    [:type, const_value: :numeric_range],
    [:id, :fixnum, :mandatory],
    [:value, :range, :mandatory],
  )

  SelectionGroup = EntityUtils.define_builder(
    [:type, const_value: :selection_group],
    [:id, :fixnum, :mandatory],
    [:value, :array, :mandatory],
    [:operator, one_of: [:and, :or]]
  )

  SearchParams = EntityUtils.define_builder(
    [:page, :to_integer, default: 1, gte: 1],
    [:per_page, :to_integer, :mandatory, gte: 1],
    [:keywords, :string, :optional],
    [:latitude, :to_float, :optional],
    [:longitude, :to_float, :optional],
    [:distance_max, :to_float, :optional],
    [:scale, :to_float, :optional],
    [:offset, :to_float, :optional],
    [:sort, :symbol, :optional],
    [:distance_unit, :symbol, :optional],
    [:categories, :array, :optional],
    [:listing_shape_ids, :array, :optional],
    [:price_cents, :range, :optional],
    [:fields, :array, default: []],
    [:author_id, :string],
    [:include_closed, :to_bool, default: false],
    [:locale, :symbol, :optional]
  )

  AvatarImage = EntityUtils.define_builder(
    [:thumb, :string],
  )

  ListingImage = EntityUtils.define_builder(
    [:thumb, :string],
    [:small_3x2, :string],
    [:medium, :string],
  )

  Author = EntityUtils.define_builder(
    [:id, :string, :mandatory],
    [:username, :string, :mandatory],
    [:first_name, :string, :optional],
    [:last_name, :string, :optional],
    [:display_name, :string, :optional],
    [:avatar, entity: AvatarImage],
    [:is_deleted, :bool, default: false],
    [:num_of_reviews, :fixnum, default: 0]
  )

  Listing = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory, :to_integer],
    [:url, :string, :mandatory],
    # This is an ugly fix. Title should be mandatory, but if the title contains only unsupported characters
    # it may happen that the title is empty and exception will be thrown.
    # This can be removed when we properly support wider range of characters, e.g. after Rails 4 update.
    [:title, :string, :optional],
    [:description, :string],
    [:category_id, :fixnum, :mandatory],
    [:author, entity: Author],
    [:listing_images, collection: ListingImage],
    [:updated_at, :time, :mandatory, str_to_time: "%Y-%m-%dT%H:%M:%S.%L%z"], # 2014-12-08T20:51:29.000+0200
    [:created_at, :time, :mandatory, str_to_time: "%Y-%m-%dT%H:%M:%S.%L%z"],
    [:latitude],
    [:longitude],
    [:distance, :optional],
    [:distance_unit, :optional],
    [:address, :string],
    [:comment_count, :fixnum, :optional],
    [:price, :money],
    [:unit_tr_key, :string], # TODO is this mandatory?
    [:unit_type], # TODO Symbol or string?
    [:quantity, :string], # This is outdated
    [:shape_name_tr_key, :string], # TODO is this mandatory?
    [:listing_shape_id, :fixnum, :optional], # This can be nil, if the listing shape was deleted
  )

  ListingIndexResult = EntityUtils.define_builder(
    [:count, :fixnum, :mandatory],
    [:listings, collection: Listing]
  )

  module_function

  def create_search_params(h)
    fields = parse_fields(h[:fields])

    SearchParams.call(
      h.merge(fields: fields)
    )
  end

  def parse_fields(fields)
    (fields || []).map { |f|
      case f[:type]
      when :numeric_range
        NumericRange.call(f)
      when :selection_group
        SelectionGroup.call(f)
      else
        ArgumentError.new("Unknown field type: #{f[:type]}")
      end
    }
  end
end
