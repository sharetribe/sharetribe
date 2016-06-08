module HashUtils
  module_function

  def compact(h)
    h.reject { |k, v| v.nil? }
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

  def map_values(h, &block)
    h.inject({}) do |memo, (k, v)|
      memo[k] = block.call(v)
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

  def stringify_keys(h)
    map_keys(h) { |k| k.to_s }
  end

  def map_keys(h, &block)
    Hash[h.map { |(k, v)| [block.call(k), v] }]
  end

  # Select values by given keys from array of hashes
  #
  # Usage:
  # pluck([{name: "John", age: 15}, {name: "Joe"}], :name, :age) => ["John", "Joe", 15]
  def pluck(array_of_hashes, *keys)
    array_of_hashes.map { |h|
      keys.map { |key| h[key] }
    }.flatten.compact
  end

  # Select a subset of the hash h using given set of keys.
  # Only include keys that are present in h.
  #
  # Usage:
  #   sub({first: "First", last: "Last", age: 55}, :first, :age, :sex)
  #   => {first: "First", age: 55}
  def sub(h, *keys)
    keys.reduce({}) do |sub_hash, k|
      sub_hash[k] = h[k] if h.has_key?(k)
      sub_hash
    end
  end

  # Return true if given subset of fields in both hashes are equal
  #
  # Usage:
  #  suq_eq({a: 1, b: 2, c: 3}, {a: 1, b: 2, c: 4}, :a, :b) => true
  def sub_eq(a, b, *keys)
    a.slice(*keys) == b.slice(*keys)
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

  # wrap_if_present(:wrap, {a: 1}} -> {wrap: {a: 1}}
  # wrap_if_present(:wrap, {}} -> {}
  # wrap_if_present(:wrap, nil) -> {}
  def wrap_if_present(key, value)
    Maybe(value).map { |v|
      Hash[key, v]
    }.or_else({})
  end

  # { 1: [15], 2: [15, 16] => { 15: [1, 2], 16: [2] }
  #
  def transpose(x)
    x.reduce({}) { |acc, (key, value)|
      value.each { |v|
        acc[v] = (acc[v] || Set.new) << key
      }
      acc
    }.map { |(k, v)| [k, v.to_a] }.to_h
  end

  # { a: b: 1 } -> { :"a.b" => 1 }
  def flatten(h)
    # use helper lambda
    acc = ->(prefix, hash) {
      hash.inject({}) { |memo, (k, v)|
        key_s = k.to_s

        if !k.is_a?(Symbol) || key_s.include?(".")
          raise ArgumentError.new("Key must be a Symbol and must not contain dot (.). Was: '#{k.to_s}', (#{k.class.name})")
        end

        prefixed_key = prefix.nil? ? k : [prefix.to_s, key_s].join(".")

        if v.is_a? Hash
          memo.merge(acc.call(prefixed_key, v))
        else
          memo.merge(prefixed_key.to_sym => v)
        end
      }
    }

    acc.call(nil, h)
  end
end
