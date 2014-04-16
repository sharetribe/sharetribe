module Util
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
  end

  module CamelizeHash
    def to_hash
      Util::HashUtils.camelize_keys(instance_hash(self))
    end

    module_function

    def instance_hash(instance)
      instance.instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@")] = instance.instance_variable_get(var)
        hash
      end
    end
  end

  module ArrayUtils
    module_function

    def next_and_prev(arr, curr)
      if arr.length <= 1
        [nil, nil]
      elsif arr.length == 2
        first, last = arr
        curr == first ? [last, last] : [first, first]
      else
        prev, mid, nexxt = each_cons_repeat(arr, 3).find { |(prev, mid, nexxt)| mid == curr  }
        [prev, nexxt]
      end
    end

    # Same as `each_cons` but repeats from the start
    #
    # Example:
    # [1, 2, 3, 4].each_cons(3) => [1, 2, 3], [2, 3, 4]
    #
    # [1, 2, 3, 4].each_cons_repeat(3) => [1, 2, 3], [2, 3, 4], [3, 4, 1], [4, 1, 2]
    def each_cons_repeat(arr, cons)
      (arr + arr.take(cons - 1)).each_cons(cons)
    end

    # Give array `xs` and number of `columns` to split. Get back array of columns
    #
    # each_slice_columns([1, 2, 3, 4, 5, 6, 7], 3) -> [[1, 2, 3], [4, 5], [6, 7]]
    def each_slice_columns(xs, columns, &block)
      div = xs.length / columns.to_f
      first_length = div.ceil
      rest_length = div.round

      first = xs.take(first_length)
      rest = rest_length > 0 ? xs.drop(first_length).each_slice(rest_length).to_a : []

      result = [first].concat(rest)

      if block
        result.each &block
      else
        result.each
      end
    end
  end

  module MoneyUtil
    module_function

    # Give string that represents money and get back the amount in cents
    #
    # Notice! The parsing strategy should follow the frontend validation strategy
    def parse_money_to_cents(money_str)
      # Current front-end validation: /^\d+((\.|\,)\d{0,2})?$/
      normalized = money_str.sub(",", ".");
      cents = normalized.to_f * 100
      cents.to_i
    end
  end

  module StringUtils
    module_function

    def first_words(str, word_count=15)
      str.split(" ").take(word_count).join(" ")
    end

    # this is a text -> this text (letter_count: 2)
    def strip_small_words(str, min_letter_count=2)
      str.split(" ").select { |word| strip_punctuation(word).length > min_letter_count }.join(" ")
    end

    def strip_punctuation(str)
      str.gsub(/[^[[:word:]]\s]/, '')
    end

    def keywords(str, word_count=10, min_letter_count=2)
      strip_punctuation(first_words(strip_small_words(str, min_letter_count), word_count)).downcase.split(" ").join(", ")
    end
  end
end
