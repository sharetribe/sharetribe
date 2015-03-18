module ListingService::Store::Shapes

  TransactionTypeModel = ::TransactionType
  ListingUnitModel = ::ListingUnit

  NewShape = EntityUtils.define_builder(
    [:community_id, :fixnum, :mandatory],
    [:price_enabled, :bool, :mandatory],
    [:transaction_process_id, :fixnum, :mandatory],
    [:translations, :array, :optional], # TODO Only temporary
    [:units, :array, :mandatory],
  )

  Shape = EntityUtils.define_builder(
    # TODO Currently we don't have Shape model, i.e. we don't have Shape id
    # [:id, :fixnum, :mandatory]
    [:transaction_type_id, :fixnum, :optional], # TODO Only temporary
    [:community_id, :fixnum, :mandatory],
    [:price_enabled, :to_bool, :mandatory], # to_bool, because there are NULL values in db
    [:transaction_process_id, :fixnum, :mandatory],
    [:translations, :array, :optional], # TODO Only temporary
    [:units, :array, :mandatory]
  )

  Unit = EntityUtils.define_builder(
    [:type, :to_symbol, one_of: [:piece, :hour, :day, :night, :week, :month, :custom]],
    [:translation_key, :optional] # TODO Validate or transform to TranslationKey
    )

  module_function

  # TODO Remove transaction_type_id
  def get(community_id:, transaction_type_id: nil, listing_shape_id: nil)
    if transaction_type_id
      model = TransactionTypeModel.where(community_id: community_id, id: transaction_type_id).first
      from_transaction_type_model(model)
    elsif listing_shape_id
      raise NotImplementedError.new("Can not find listing shape by listing_shape_id, yet. Specify transaction_type_id instead.")
    else
      rase ArgumentError.new("Can not find listing shape without id.")
    end
  end

  def create(community_id:, opts:)
    shape = NewShape.call(opts.merge(community_id: community_id))
    units = opts[:units].map { |unit| Unit.call(unit) }
    translations = opts[:translations] # Skip data type and validation, because this is temporary

    # TODO We should be able to create transaction_type without community
    community = Community.find(shape[:community_id])

    create_tt_opts = to_tt_model_attributes(shape).except(:units, :translations)
    tt_model = community.transaction_types.build(create_tt_opts)
    units.each { |unit|
      tt_model.listing_units.build(to_unit_model_attributes(unit))
    }
    translations.each { |tr| tt_model.translations.build(tr) }

    tt_model.save!

    from_transaction_type_model(tt_model)
  end

  # private

  def from_transaction_type_model(model)
    Maybe(model).map { |m|
      hash = from_tt_model_attributes(EntityUtils.model_to_hash(m))

      hash[:units] = m.listing_units.map { |unit_model|
        Unit.call(from_unit_model_attributes(EntityUtils.model_to_hash(unit_model)))
      }

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

  def to_tt_model_attributes(hash)
    HashUtils.rename_keys(
      {
        price_enabled: :price_field
      }, hash)
  end

  def from_tt_model_attributes(hash)
    HashUtils.rename_keys(
      {
        price_field: :price_enabled,
        id: :transaction_type_id
      }, hash)
  end

end
