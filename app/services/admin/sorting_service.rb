module Admin
  module SortingService
    class << self
      def next_sort_priority(sortables)
        next_int(sortables.collect(&:sort_priority))
      end

      # Give array of integers (can include nils) and get back
      # next integer
      #
      # Examples:
      # [] => 1
      # [nil] => 1
      # [1, 2, 3] => 4
      # [1, nil, 2, nil, 99] => 100
      def next_int(xs)
        (xs.compact.max || 0) + 1
      end
    end
  end
end
