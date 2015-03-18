module ListingService::Store::Shapes

  TransactionTypeModel = ::TransactionType
  ListingUnitModel = ::ListingUnit

  NewShape = EntityUtils.define_builder(
    [:units, :array, :mandatory]
  )

  Shape = EntityUtils.define_builder(
    # TODO Currently we don't have Shape model, i.e. we don't have Shape id
    # [:id, :fixnum, :mandatory]
    [:transaction_type_id, :fixnum, :optional], # TODO Only temporary
    [:community_id, :fixnum, :mandatory],
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

  def create(community_id:, transaction_type_id:, opts:)
    shape = NewShape.call(opts.merge(community_id: community_id))
    units = opts[:units].map { |unit| Unit.call(unit) }

    # TODO only units are saved. Save also transaction_type_id to units.
    saved_units = units.map { |unit|
      Unit.call(
        HashUtils.rename_keys({unit_type: :type},
          EntityUtils.model_to_hash(
            ListingUnit.create!(
              HashUtils.rename_keys({type: :unit_type}, unit).merge(
                transaction_type_id: transaction_type_id)))))
    }
  end

  def from_transaction_type_model(model)
    Maybe(model).map { |m|
      hash = HashUtils.rename_keys({id: :transaction_type_id}, EntityUtils.model_to_hash(m))
      hash[:units] = m.listing_units.map { |unit_model|
        Unit.call(HashUtils.rename_keys({ unit_type: :type }, EntityUtils.model_to_hash(unit_model))) }
      Shape.call(hash)
    }.or_else(nil)
  end

end
