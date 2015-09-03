module ListingService::Store::Category

  CategoryModel = ::Category

  NewCategory = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:parent_id, :fixnum],
    [:sort_priority, :fixnum, default: 0],
    [:translations, :array, :mandatory],
    [:basename, :string, :mandatory]
  )

  Category = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:community_id, :fixnum, :mandatory],
    [:parent_id, :fixnum],
    [:sort_priority, :fixnum, default: 0],
    [:name, :string, :mandatory],
    [:listing_shape_ids, :array, default: []],
    [:translations, :array, :mandatory],
    [:children, :array, default: []]
  )

  Translation = EntityUtils.define_builder(
    [:locale, :string, :mandatory],
    [:name, :string, :mandatory]
  )

  module_function

  def get_all(community_id:)
    models = CategoryModel.where(community_id: community_id, parent_id: nil).order(:sort_priority)
    models.map { |model| from_model(model) }
  end

  def create(community_id:, opts:)
    category = NewCategory.call(opts.merge(community_id: community_id))
    category_model = CategoryModel.new(category.except(:translations))
    category_model.translations.build(category[:translations])
    category_model.save!

    from_model(category_model)
  end

  # private

  def from_model(category_model)
    Maybe(category_model).map { |m|
      hash = EntityUtils.model_to_hash(m)

      hash[:translations] = m.translations.map { |t|
        Translation.call(EntityUtils.model_to_hash(t))
      }

      hash[:children] = m.children.map { |child|
        from_model(child)
      }

      hash[:listing_shape_ids] = m.listing_shapes.pluck(:id)

      Category.call(from_model_attributes_to_entity(hash))
    }.or_else(nil)
  end

  def from_model_attributes_to_entity(model_attributes)
    HashUtils.rename_keys({url: :name}, model_attributes)
  end
end
