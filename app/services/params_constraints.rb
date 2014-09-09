# Use this helper class in routes.rb to do routing based on
# request params.
#
# Give `expected_params` as a hash with expected
#
class ParamsConstraints
  def initialize(expected_params)
    @expected = expected_params
  end

  def matches?(request)
    HashUtils.deep_contains(@expected, request.params)
  end
end
