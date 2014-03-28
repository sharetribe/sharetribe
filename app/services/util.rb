module Util
  module Hash
    class << self
      def compact(h)
        h.delete_if { |k, v| v.nil? }
      end
    end
  end
end
