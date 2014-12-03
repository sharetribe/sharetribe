module EntityUtils
  module_function

  # Define an entity constructor Proc, which returns a Hash
  #
  # Usage:
  #
  # -- in some service / Entity --
  #
  # Person = EntityUtils.define_entity(
  #   :username,
  #   :password)
  #
  # -- in some service / Query --
  #
  # def person(person_id)
  #   Maybe(Person.where(person_id: person_id.first)
  #     .map { |model| Person.call(model) }
  #     .or_else(nil)
  # end
  #
  def define_entity(*ks)
    -> (opts = {}) {

      ks.reduce({}) do |memo, k|
        memo[k.to_sym] = opts[k]
        memo
      end
    }
  end

  # Turn active record model into a hash with string keys replaced with symbols
  def model_to_hash(model)
    return {} if model.nil?
    HashUtils.symbolize_keys(model.attributes)
  end

  VALIDATORS = {
    mandatory: -> (_, v, field) {
      if (v.to_s.empty?)
        "#{field}: Missing mandatory value."
      end
    },
    optional: -> (_, v, field) { nil },
    one_of: -> (allowed, v, field) {
      unless (allowed.include?(v))
        "#{field}: Value must be one of #{allowed}. Was: #{v}."
      end
    },
    string: -> (_, v, field) {
      unless (v.nil? || v.is_a?(String))
        "#{field}: Value must be a String. Was: #{v} (#{v.class.name})."
      end
    },
    time: -> (_, v, field) {
      unless (v.nil? || v.is_a?(Time))
        "#{field}: Value must be a Time. Was: #{v} (#{v.class.name})."
      end
    },
    fixnum: -> (_, v, field) {
      unless (v.nil? || v.is_a?(Fixnum))
        "#{field}: Value must be a Fixnum. Was: #{v} (#{v.class.name})."
      end
    },
    symbol: -> (_, v, field) {
      unless (v.nil? || v.is_a?(Symbol))
        "#{field}: Value must be a Symbol. Was: #{v} (#{v.class.name})."
      end
    },
    hash: -> (_, v, field) {
      unless (v.nil? || v.is_a?(Hash))
        "#{field}: Value must be a Hash. Was: #{v} (#{v.class.name})."
      end
    },
    callable: -> (_, v, field) {
      unless (v.nil? || v.respond_to?(:call))
        "#{field}: Value must respond to :call, i.e. be a Method or a Proc (lambda, block, etc.)."
      end
    },
    enumerable: -> (_, v, field) {
      unless (v.nil? || v.is_a?(Enumerable))
        "#{field}: Value must be an Enumerable. Was: #{v}."
      end
    },
    money: -> (_, v, field) {
      unless (v.nil? || v.is_a?(Money))
        "#{field}: Value must be a Money. Was: #{v}."
      end
    },
    validate_with: -> (validator, v, field) {
      unless (validator.call(v))
        "#{field}: Custom validation failed. Was: #{v}."
      end
    }
  }

  TRANSFORMERS = {
    const_value: -> (const, v) { const },
    default: -> (default, v) { v.nil? ? default : v },
    to_bool: -> (_, v) { !!v },
    to_symbol: -> (_, v) { v.to_sym },
    str_to_time: -> (format, v) {
      if v.nil?
        nil
      elsif v.is_a?(Time)
        v
      elsif format.nil?
        raise "Can not transform string #{v} to time. Format missing."
      elsif !format.match(/z/i)
        raise "Format #{format} does not contain timezone information. I don't know in which timezone the string time is"
      else
        Time.strptime(v, format)
      end
    },
    utc_str_to_time: -> (_, v) {
      if v.nil?
        nil
      elsif v.is_a?(Time)
        v
      else
        TimeUtils::utc_str_to_time(v)
      end
    },
    transform_with: -> (transformer, v) { transformer.call(v) }
  }

  def validator_or_transformer(k)
    if (VALIDATORS.keys.include?(k))
      :validators
    elsif (TRANSFORMERS.keys.include?(k))
      :transformers
    else
      raise(ArgumentError, "Illegal key #{k}. Not a known transformer or validator.")
    end
  end

  def parse_spec(spec)
    s = spec.dup
    opts = s.extract_options!
    parsed_spec = s.zip([nil].cycle)
      .to_h
      .merge(opts)
      .group_by { |(name, param)| validator_or_transformer(name) }

    parsed_spec[:validators] =
      (parsed_spec[:validators] || [])
      .map { |(name, param)| VALIDATORS[name].curry().call(param) }
    parsed_spec[:transformers] =
      (parsed_spec[:transformers] || [])
      .map { |(name, param)| TRANSFORMERS[name].curry().call(param) }

    parsed_spec
  end

  def parse_specs(specs)
    specs.reduce({}) do |fs, full_field_spec|
      f_name, *spec = *full_field_spec
      fs[f_name] = parse_spec(spec)
      fs
    end
  end

  def validate(validators, val, field)
    validators.reduce([]) do |res, validator|
      err = validator.call(val, field)
      res.push(err) unless err.nil?
      res
    end
  end

  def transform(transformers, val)
    transformers.reduce(val) do |v, transformer|
      transformer.call(v)
    end
  end

  def transform_and_validate(fields, input)
    output = fields.reduce({}) do |out, (name, spec)|
      out[name] = transform(spec[:transformers], input[name])
      out
    end

    errors = fields.reduce([]) do |errs, (name, spec)|
      errs.concat(validate(spec[:validators], output[name], name))
    end

    {value: output, errors: errors}
  end

  # Define a builder function that constructs a new hash from an input
  # hash.
  #
  # Builders require you to define a set of fields with (optional)
  # sets of per field validators and transformers.
  #
  # The main purpose of validators is to document the format that the
  # entity builder produces.  The other thing is to catch programmer
  # mistakes that would have led to values not matching the documented
  # behavior. This is done by validating the output of the builder and
  # throwing a helpful error msg in case there's a mismatch.
  #
  # You can additionally specify transformers, which are mainly useful
  # for coercing the incoming data to match the desired output
  # format. You can e.g. provide default values, convert to bool or
  # convert a string to a time. Every transformer must be idempotent,
  # which is a fancy way of saying that tx(x) == tx(tx(x)), which is a
  # math-like expression meaning we can apply the transformer to a
  # value an arbitrary number of times and will always get the same
  # result no matter how many times (> 0) we did it.
  #
  # Here's an example:
  #
  # Person = EntityUtils.define_builder(
  #   # const_value tranformer always returns the given const value, in this case :person
  #   [:type, const_value: :person],
  #
  #   # combining validators, must be string (:string) and not-nil (:mandatory)
  #   [:name, :string, :mandatory],
  #
  #   # :default transformer sets value if it's nil
  #   [:age, :fixnum, default: 8],
  #
  #   # accepts only :m, :f and :in_between
  #   [:sex, one_of: [:m, :f, :in_between]],
  #
  #   # custom validator, return true for valid values
  #   [:favorite_even_number, validate_with: -> (v) { v.nil? || v.even? }],
  #
  #   # custom transformer, return transformed value
  #   [:tag, :optional, transform_with: -> (v) { v.to_sym unless v.nil? }]
  # )
  #
  # See rspec tests for more examples and output
  def define_builder(*specs)
    fields = parse_specs(specs)

    -> (opts = {}) do
      raise(TypeError, "Expecting an input hash. You gave: #{opts}") unless opts.is_a? Hash

      result = transform_and_validate(fields, opts)

      unless (result[:errors].empty?)
        loc = caller_locations(2, 1).first
        raise(ArgumentError, "Error(s) in #{loc}: #{result[:errors]}")
      end

      result[:value]
    end
  end

end
