# Implement Comparable module (method `sort`) by
# sorting per `sort_priority`. nil acts as 0
module SortableByPriority
  include Comparable

  def <=> other
    (sort_priority || 0) <=> (other.sort_priority || 0)
  end
end