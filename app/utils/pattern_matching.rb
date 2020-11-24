# Pattern matching helper
#
# Use `matches` to match an array in a way that looks like pattern matching
#
# Example:
#
# case [a, b]
# when matches([true])
#  "matches when a is `true`"
# when matches([true, true])
#  "matches when a and b are `true`"
# when matches([__, true])
#  "matches when b is `true`"
# when matches([false, (4..10)])
#  "matches when a is `false` and b is number in range 4-10"
# when matches([Array, Hash])
#  "matches when a is an `Array` and b is a `Hash`"
#
#
def matches(expected)
  ->(actual) {
    expected.zip(actual).all? do |(exp, act)|
      exp === act
    end
  }
end

def __
  ->(x) { true }
end
