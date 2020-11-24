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

  def get(community:, name:, locales:)
    shape = community.shapes.by_name(name).first
    if shape
      process = shape.transaction_process
      raise ArgumentError.new("Cannot find process with id: #{shape[:transaction_process_id]}") if process.nil?

      shape_with_process = EntityUtils.model_to_hash(shape).merge(online_payments: process.process == :preauthorize, author_is_seller: process.author_is_seller)

      with_translations = TranslationServiceHelper.tr_keys_to_form_values(
        entity: shape_with_process,
        locales: locales,
        key_map: KEY_MAP
      ).merge(
        units: shape.units.map do |u|
          TranslationServiceHelper.tr_keys_to_form_values(
            entity: u,
            locales: locales,
            key_map: CUSTOM_UNIT_KEY_MAP
          )
        end
      )
      Result::Success.new(Shape.call(with_translations))
    end
  end

  def update(community:, name:, opts:)
    old_shape = community.shapes.by_name(name).first
    if old_shape
      shape_opts = Shape.call(opts)
      select_existing_units(old_shape.units, shape_opts[:units]).and_then do |new_shape_units|
        old_shape_hash = EntityUtils.model_to_hash(old_shape)
        new_shape_opts = shape_opts.merge(new_shape_units).merge(old_shape_hash.slice(:name_tr_key, :action_button_tr_key))
        shape = process_shape(community_id: community.id, opts: new_shape_opts)
        validate_upsert_opts(shape).and_then { |update_opts|
          Maybe(old_shape.update_with_opts(update_opts)).map { |updated_shape|
            Result::Success.new(updated_shape)
          }.or_else {
            Result::Error.new("Cannot find listing shape for #{find_opts}")
          }
        }
      end
    else
      Result::Error.new("Cannot find listing shape for #{name}")
    end
  end

  def create(community:, default_locale:, opts:)
    shape_opts = Shape.call(opts)
    shape = process_shape(community_id: community.id, opts: shape_opts)

    with_basename = shape.merge(basename: shape[:name][default_locale])

    validate_upsert_opts(with_basename.merge(community_id: community.id)).and_then { |create_opts|
      Result::Success.new(ListingShape.create_with_opts(community: community, opts: create_opts))
    }
  end

  private

  def process_shape(community_id:, opts:)
    TranslationServiceHelper.form_values_to_tr_keys!(
      entity: opts,
      key_map: KEY_MAP,
      community_id: community_id
    ).merge(
      units: opts[:units].map { |u| add_quantity_selector(u) }.map{ |u| add_custom_unit_translation(u, community_id)}.map{ |u| add_kind(u) },
      transaction_process_id: select_process(opts[:online_payments], opts[:author_is_seller], @processes))
  end

  def select_existing_units(old_shape_units, new_shape_units)

    unit_selections = new_shape_units.map { |u|
      if u[:name_tr_key] || u[:selector_tr_key]
        # If either name or selector is found, then consider as existing unit

        find_by_fields = [:name_tr_key, :selector_tr_key, :kind]
        new_unit_field_values = u.slice(*find_by_fields)
        selected_unit = old_shape_units.find { |old_unit| old_unit.slice(*find_by_fields) == new_unit_field_values }

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
      Result::Success.new(units: unit_selections.map(&:first))
    end
  end

  def add_custom_unit_translation(unit, community_id)
    if unit[:unit_type] == 'custom' && !unit[:name_tr_key]
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
    unit.merge(quantity_selector: ['day', 'night'].include?(unit[:unit_type]) ? unit[:unit_type] : 'number')
  end

  def add_kind(unit)
    kind =
      case unit[:unit_type]
      when 'custom' then unit[:kind]
      when 'unit' then 'quantity'
      else
        'time'
      end

    unit.merge(kind: kind)
  end

  def select_process(online_payments, author_is_seller, processes)
    process = online_payments ? :preauthorize : :none
    selected = processes.find { |p| p.author_is_seller == author_is_seller && p.process == process }

    raise ArgumentError.new("Cannot find suitable process") if selected.nil?

    selected[:id]
  end

  def validate_upsert_opts(opts)
    error =
      if opts[:availability] == 'booking'
        if opts[:units].length != 1
          Result::Error.new("Only one unit is allowed if booking availability is in use. Was: #{opts[:units].inspect}")
        elsif !enabled_units.include?(opts[:units].first[:unit_type])
          Result::Error.new("Only day or night unit is allowed if booking availability is in use. Was: #{opts[:units].inspect}")
        end
      end

    error || Result::Success.new(opts)
  end

  def enabled_units
    units = ['day', 'night', 'hour']
    units
  end
end
