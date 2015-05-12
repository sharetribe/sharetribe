# A helper module that let's you reload listing shapes by community id or
# community id and listing shape id, and gets back the shape with translations
# and process information included
class ShapeService
  Shape = ListingShapeDataTypes::Shape
  KEY_MAP = ListingShapeDataTypes::KEY_MAP

  def initialize(processes)
    @processes = processes
  end

  def get(community_id:, name:, locales:)
    listing_api.shapes.get(community_id: community_id, name: name).and_then { |shape|
      process = @processes.find { |p| p[:id] == shape[:transaction_process_id] }

      raise ArgumentError.new("Can not find process with id: #{shape[:transaction_process_id]}") if process.nil?

      shape_with_process = shape.merge(online_payments: process[:process] == :preauthorize, author_is_seller: process[:author_is_seller])

      with_translations = TranslationServiceHelper.tr_keys_to_form_values(
        entity: shape_with_process,
        locales: locales,
        key_map: KEY_MAP
      )

      Result::Success.new(Shape.call(with_translations))
    }
  end

  def update(community_id:, name:, opts:)
    listing_api.shapes.get(community_id: community_id, name: name).and_then { |old_shape|
      shape_opts = Shape.call(opts)
      shape = process_shape(community_id: community_id, opts: shape_opts.merge(old_shape.slice(:name_tr_key, :action_button_tr_key)))

      listing_api.shapes.update(
        community_id: community_id,
        name: name,
        opts: shape
      )
    }
  end

  def create(community_id:, default_locale:, opts:)
    shape_opts = Shape.call(opts)
    shape = process_shape(community_id: community_id, opts: shape_opts)

    with_basename = shape.merge(
      basename: shape[:name][default_locale]
    )

    listing_api.shapes.create(
      community_id: community_id,
      opts: with_basename
    )
  end

  private

  def process_shape(community_id:, opts:)
    TranslationServiceHelper.form_values_to_tr_keys!(
      entity: opts,
      key_map: KEY_MAP,
      community_id: community_id
    ).merge(
      units: opts[:units].map { |u| add_quantity_selector(u) },
      transaction_process_id: select_process(opts[:online_payments], opts[:author_is_seller], @processes))
  end

  def listing_api
    ListingService::API::Api
  end

  def add_quantity_selector(unit)
    unit.merge(quantity_selector: unit[:type] == :day ? :day : :number)
  end

  def select_process(online_payments, author_is_seller, processes)
    process = online_payments ? :preauthorize : :none
    selected = processes.find { |p| p[:author_is_seller] == author_is_seller && p[:process] == process }

    raise ArugmentError.new("Can not find suitable process") if selected.nil?

    selected[:id]
  end

end
