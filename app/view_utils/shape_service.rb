# A helper module that let's you reload listing shapes by community id or
# community id and listing shape id, and gets back the shape with translations
# and process information included
class ShapeService
  Shape = ListingShapeDataTypes::Shape
  KEY_MAP = ListingShapeDataTypes::KEY_MAP
  CUSTOM_UNIT_KEY_MAP = ListingShapeDataTypes::CUSTOM_UNIT_KEY_MAP

  def initialize(processes)
    @processes = processes
  end

  def get(community_id:, name:, locales:)
    listing_api.shapes.get(community_id: community_id, name: name).and_then { |shape|
      process = @processes.find { |p| p[:id] == shape[:transaction_process_id] }

      raise ArgumentError.new("Cannot find process with id: #{shape[:transaction_process_id]}") if process.nil?

      shape_with_process = shape.merge(online_payments: process[:process] == :preauthorize, author_is_seller: process[:author_is_seller])

      with_translations = TranslationServiceHelper.tr_keys_to_form_values(
        entity: shape_with_process,
        locales: locales,
        key_map: KEY_MAP
      ).merge(
        units: shape_with_process[:units].map do |u|
          TranslationServiceHelper.tr_keys_to_form_values(
            entity: u,
            locales: locales,
            key_map: CUSTOM_UNIT_KEY_MAP
          )
        end
      )

      Result::Success.new(Shape.call(with_translations))
    }
  end

  def update(community_id:, name:, opts:)
    listing_api.shapes.get(community_id: community_id, name: name).and_then { |old_shape|
      shape_opts = Shape.call(opts)
      select_existing_units(old_shape, shape_opts)
    }.and_then { |old_shape, new_shape_opts|
      shape = process_shape(community_id: community_id, opts: new_shape_opts.merge(old_shape.slice(:name_tr_key, :action_button_tr_key)))
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
      units: opts[:units].map { |u| add_quantity_selector(u) }.map { |u| add_custom_unit_translation(u, community_id) },
      transaction_process_id: select_process(opts[:online_payments], opts[:author_is_seller], @processes))
  end

  def select_existing_units(old_shape, new_shape)

    unit_selections = new_shape[:units].map { |u|
      if u[:name_tr_key] || u[:selector_tr_key]
        # If either name or selector is found, then consider as existing unit

        find_by_fields = [:name_tr_key, :selector_tr_key, :kind]
        new_unit_field_values = u.slice(*find_by_fields)
        selected_unit = old_shape[:units].find { |old_unit| old_unit.slice(*find_by_fields) == new_unit_field_values }

        if selected_unit
          [selected_unit]
        else
          [nil, "Couldn't find existing unit for #{new_unit_field_values}"]
        end
      else
        # Return new units
        [u]
      end
    }

    errors = unit_selections.map(&:second).reject(&:nil?)

    if errors.first
      Result::Error.new(errors.first)
    else
      Result::Success.new([old_shape, new_shape.merge(units: unit_selections.map(&:first))])
    end
  end

  def listing_api
    ListingService::API::Api
  end

  def add_custom_unit_translation(unit, community_id)
    if unit[:type] == :custom && !unit[:name_tr_key]
      TranslationServiceHelper.form_values_to_tr_keys!(
        entity: unit,
        key_map: CUSTOM_UNIT_KEY_MAP,
        community_id: community_id
      )
    else
      unit
    end
  end

  def add_quantity_selector(unit)
    unit.merge(quantity_selector: unit[:type] == :day ? :day : :number)
  end

  def select_process(online_payments, author_is_seller, processes)
    process = online_payments ? :preauthorize : :none
    selected = processes.find { |p| p[:author_is_seller] == author_is_seller && p[:process] == process }

    raise ArgumentError.new("Cannot find suitable process") if selected.nil?

    selected[:id]
  end

end
