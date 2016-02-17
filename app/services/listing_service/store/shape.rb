module ListingService::Store::Shape

  ListingUnitModel = ::ListingUnit
  CategoryModel = ::Category
  CategoryListingShapeModel = ::CategoryListingShape

  NewShape = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:price_enabled, :bool, :mandatory],
    [:name_tr_key, :string, :mandatory],
    [:action_button_tr_key, :string, :mandatory],
    [:transaction_process_id, :fixnum, :mandatory],
    [:shipping_enabled, :bool, :mandatory],
    [:units, :array, default: []], # Mandatory only if price_enabled
    [:sort_priority, :fixnum],
    [:basename, :string, :mandatory]
  )

  Shape = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:community_id, :fixnum, :mandatory],
    [:price_enabled, :bool, :mandatory],
    [:name_tr_key, :string, :mandatory],
    [:action_button_tr_key, :string, :mandatory],
    [:transaction_process_id, :fixnum, :mandatory],
    [:units, :array, :mandatory],
    [:shipping_enabled, :bool, :mandatory],
    [:name, :string, :mandatory],
    [:sort_priority, :fixnum, default: 0],
    [:category_ids, :array]
  )

  UpdateShape = EntityUtils.define_builder(
    [:price_enabled, :bool],
    [:name_tr_key, :string],
    [:action_button_tr_key, :string],
    [:transaction_process_id, :fixnum],
    [:units, :array],
    [:shipping_enabled, :bool],
    [:sort_priority, :fixnum]
  )

  BuiltInUnit = EntityUtils.define_builder(
    [:type, :to_symbol, one_of: [:hour, :day, :night, :week, :month]],
    [:kind, :to_symbol, const_value: :time],
    [:name_tr_key],
    [:selector_tr_key],
    [:quantity_selector, :to_symbol, one_of: ["".to_sym, :none, :number, :day]] # in the future include :hour, :week:, :night ,:month etc.
  )

  CustomUnit = EntityUtils.define_builder(
    [:type, :to_symbol, one_of: [:custom]],
    [:kind, :to_symbol, one_of: [:time, :quantity]],
    [:name_tr_key, :string, :mandatory],
    [:selector_tr_key, :string, :mandatory],
    [:quantity_selector, :to_symbol, one_of: ["".to_sym, :none, :number, :day]] # in the future include :hour, :week:, :night ,:month etc.
  )

  DEFAULT_BASENAME = 'order_type'

  module_function

  def get(community_id:, listing_shape_id: nil, name: nil, include_categories:)
    shape_model = find_shape_model(
      community_id: community_id,
      listing_shape_id: listing_shape_id,
      name: name)

    from_model(shape_model, include_categories)
  end

  def get_all(community_id:, include_categories:)
    shape_models = find_shape_models(community_id: community_id)

    shape_models.map { |shape_model|
      from_model(shape_model, include_categories)
    }
  end

  def create(community_id:, opts:)
    shape = NewShape.call(opts.merge(community_id: community_id))

    units = shape[:units].map { |unit| to_unit(unit) }

    shapes = find_shape_models(community_id: community_id)
    name = uniq_name(shapes, shape[:basename], shape[:community_id])
    shape_with_name = shape.except(:basename).merge(name: name)

    shape_with_sort = shape_with_name.merge(
      sort_priority: shape_with_name[:sort_priority] || next_sort_priority(shapes)
    )

    ActiveRecord::Base.transaction do

      # Save to ListingShape model
      shape_model = ListingShape.create!(shape_with_sort.except(:units))

      # Save units
      units.each { |unit|
        shape_model.listing_units.create!(to_unit_model_attributes(unit))
      }

      assign_to_categories!(community_id, shape_model.id)

      from_model(shape_model, true)
    end
  end

  def update(community_id:, listing_shape_id: nil, name: nil, opts:)
    shape_model = find_shape_model(
      community_id: community_id,
      listing_shape_id: listing_shape_id,
      name: name)

    return nil if shape_model.nil?

    update_shape = UpdateShape.call(opts.merge(community_id: community_id))

    skip_units = update_shape[:units].nil?
    units = update_shape[:units].map { |unit| to_unit(unit) } unless skip_units

    ActiveRecord::Base.transaction do
      unless skip_units
        shape_model.listing_units.destroy_all
        units.each { |unit| shape_model.listing_units.build(to_unit_model_attributes(unit)) }
      end

      # Save to ListingShape model
      shape_model.update_attributes!(HashUtils.compact(update_shape).except(:units))
    end

    from_model(shape_model, true)
  end

  def delete(community_id:, listing_shape_id: nil, name: nil)
    shape_model = find_shape_model(
      community_id: community_id,
      listing_shape_id: listing_shape_id,
      name: name)

    return nil if shape_model.nil?

    shape_model.update_attributes(deleted: true)

    from_model(shape_model, true)
  end

  # private

  # Note: If this method is needed in Category Store, then consider separating this code to
  # own store, CategoryListingShapeStore
  def assign_to_categories!(community_id, shape_id)
    categories = CategoryModel.where(community_id: community_id)
    categories.pluck(:id).each { |category_id|
      CategoryListingShapeModel.create!(category_id: category_id, listing_shape_id: shape_id)
    }
  end

  def to_unit(hash)
    type = Maybe(hash)[:type].to_sym.or_else(nil)

    case type
    when nil
      raise ArgumentError.new("Expected unit hash with type. Instead got this hash: #{hash}")
    when :custom
      CustomUnit.call(hash)
    else
      BuiltInUnit.call(hash)
    end
  end

  def from_model(shape_model, include_categories)
    Maybe(shape_model).map { |m|
      hash = EntityUtils.model_to_hash(m)

      hash[:units] = shape_model.listing_units.map { |unit_model|
        to_unit(from_unit_model_attributes(EntityUtils.model_to_hash(unit_model)))
      }

      if include_categories
        hash[:category_ids] = shape_model.categories.pluck(:id)
      end

      Shape.call(hash)
    }.or_else(nil)
  end

  def to_unit_model_attributes(hash)
    HashUtils.rename_keys(
      {
        type: :unit_type
      }, hash)
  end

  def from_unit_model_attributes(hash)
    HashUtils.rename_keys(
      {
        unit_type: :type
      }, hash)
  end

  def find_shape_model(community_id:, listing_shape_id: nil, name: nil)
    if listing_shape_id.present?
      find_shape_models(community_id: community_id).where(id: listing_shape_id).first
    elsif name.present?
      find_shape_models(community_id: community_id).where(name: name).first
    else
      raise ArgumentError.new("Must have either name or listing shape id present")
    end
  end

  def find_shape_models(community_id:)
    ListingShape.where(community_id: community_id, deleted: false)
      .includes(:listing_units)
      .order("listing_shapes.sort_priority")
  end

  def next_sort_priority(shapes)
    max = shapes.map { |s| s[:sort_priority] }.max
    if max
      max + 1
    else
      0
    end
  end

  def uniq_name(shapes, name_source, community_id)
    blacklist = ['new', 'all']
    source = name_source.to_url
    base_name = source.present? ? source : DEFAULT_BASENAME
    current_name = base_name

    i = 1
    while blacklist.include?(current_name) || shapes.find { |s| s[:name] == current_name }.present?
      current_name = "#{base_name}#{i}"
      i += 1
    end
    current_name

  end


end
