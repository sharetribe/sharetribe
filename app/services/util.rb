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
  end

  module CamelizeHash
    module_function

    def instance_hash(instance)
      instance.instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@")] = instance.instance_variable_get(var)
        hash
      end
    end

    def to_hash
      Util::HashUtils.camelize_keys(instance_hash(self))
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
end
