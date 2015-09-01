module ListingIndexService::DataTypes
  SelectionGroups = EntityUtils.define_builder(
    [:values, :array, :mandatory],
    [:search_type, one_of: [:and, :or]],
  )

  NumericFilter = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:range, :range, :mandatory],
  )

  SearchParams = EntityUtils.define_builder(
    [:page, :to_integer, default: 1, gte: 1],
    [:per_page, :to_integer, :mandatory, gte: 1],
    [:keywords, :string, :optional],
    [:categories, :array, :optional],
    [:listing_shape_id, :fixnum, :optional],
    [:price_cents, :range, :optional],
    [:checkboxes, entity: SelectionGroups],
    [:dropdowns, entity: SelectionGroups],
    [:numbers, collection: NumericFilter],
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
    [:first_name, :string, :mandatory],
    [:last_name, :string, :mandatory],
    [:avatar, entity: AvatarImage],
    [:is_deleted, :bool, default: false],
    [:num_of_reviews, :fixnum, default: 0]
  )

  Listing = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:url, :string, :mandatory],
    [:title, :string, :mandatory],
    [:description, :string],
    [:category_id, :fixnum, :mandatory],
    [:author, entity: Author],
    [:listing_images, collection: ListingImage],
    [:updated_at, :time, :mandatory],
    [:created_at, :time, :mandatory],
    [:latitude],
    [:longitude],
    [:address, :string],
    [:comment_count, :fixnum, :optional],
    [:price, :money],
    [:unit_tr_key, :string], # TODO is this mandatory?
    [:unit_type], # TODO Symbol or string?
    [:quantity, :string], # This is outdated
    [:shape_name_tr_key, :string], # TODO is this mandatory?
    [:listing_shape_id, :fixnum, :optional], # This can be nil, if the listing shape was deleted
  )
end
