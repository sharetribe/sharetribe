module ParamUtils

  module_function

  def throw_if_any_empty(params)
    fields = params.reduce([]) do |fields, (name, value)|
      fields.push(name.to_s) if is_empty?(value)
      fields
    end

    unless (fields.empty?)
      loc = caller_locations(1, 1).first
      raise(ArgumentError, "Missing mandatory #{fields.length < 2 ? 'argument' : 'arguments'} for #{loc.label} in #{loc.path}: #{fields.join(', ')}")
    end
  end


  def is_empty?(value)
    value.to_s.empty?
  end
end
