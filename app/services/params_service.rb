# Collection of helper methods needed to handle HTTP request parameters
class ParamsService
  class << self

    # Parse number string containing either dot or comma as a decimal separator
    def parse_float(number)
      number.to_s.gsub(',', '.').to_f
    end
  end
end
