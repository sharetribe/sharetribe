module JSONUtils
  module_function

  # Takes parsed JSON and deep symbolizes the keys
  def symbolize_keys(parsed_json, type_hint = nil)
    is_array = type_hint == Array || parsed_json.is_a?(Array)
    is_hash = type_hint == Hash || parsed_json.is_a?(Hash)

    if is_hash
      Hash[parsed_json.map { |(k, v)| [k.to_sym, symbolize_value_keys(v)] }]
    elsif is_array
      parsed_json.map { |v| symbolize_value_keys(v) }
    else
      raise ArgumentError.new("Argument has to be either Array or Hash. Was #{parsed_json} (#{parsed_json.class.name})")

    end
  end

  # private

  def symbolize_value_keys(v)
    v_type = collection_type(v)
    should_traverse?(v_type) ? symbolize_keys(v, v_type) : v
  end

  def collection_type(v)
    if v.is_a?(Hash)
      Hash
    elsif v.is_a?(Array)
      Array
    else
      nil
    end
  end

  def should_traverse?(type)
    type == Hash || type == Array
  end
end
