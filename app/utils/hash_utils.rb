module HashUtils
  module_function

  def compact(h)
    h.delete_if { |k, v| v.nil? }
  end

  def camelize_keys(h, deep=true)
    h.inject({}) { |memo, (k, v)|
      memo[k.to_s.camelize(:lower).to_sym] = deep && v.is_a?(Hash) ? camelize_keys(v) : v
      memo
    }
  end

  # Give hash `h` and `regexp` which will be matched against key
  def select_by_key_regexp(h, regexp)
    h.select { |key, value| key.to_s.match(regexp) }
  end

  # Usage:
  # deep_map({foo: {bar: 2}, baz: 3}) { |k, v| v * v } -> {foo: {bar: 4}, baz: 3}
  #
  def deep_map(h, &block)
    h.inject({}) do |memo, (k, v)|
      memo[k] = if v.is_a?(Hash)
                  deep_map(v, &block)
                else
                  block.call(k, v)
                end

      memo
    end
  end

  # rename keys in given hash (returns a copy) using the renames old_key => new_key mappings
  def rename_keys(renames, hash)
    map_keys(hash) { |old_key|
      renames[old_key] || old_key
    }
  end

  def symbolize_keys(h)
    map_keys(h) { |k| k.to_sym }
  end

  def map_keys(h, &block)
    Hash[h.map { |(k, v)| [block.call(k), v] }]
  end

  #
  # deep_contains({a: 1}, {a: 1, b: 2}) => true
  # deep_contains({a: 2}, {a: 1, b: 2}) => false
  # deep_contains({a: 1, b: 1}, {a: 1, b: 2}) => false
  # deep_contains({a: 1, b: 2}, {a: 1, b: 2}) => true
  #
  def deep_contains(needle, haystack)
    needle.all? do |key, val|
      haystack_val = haystack[key]

      if val.is_a?(Hash) && haystack_val.is_a?(Hash)
        deep_contains(val, haystack_val)
      else
        val == haystack_val
      end
    end
  end

  # p = Person.new({name: "Foo", email: "foo@example.com"})
  # object_to_hash(p) => {name: "Foo" , email: "foo@example.com"}
  def object_to_hash(object)
    object.instance_variables.inject({}) do |hash, var|
      hash[var.to_s.delete("@")] = object.instance_variable_get(var)
      hash
    end
  end
end
