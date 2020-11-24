module SortableByPriority
  # Compare two object.
  #
  # Usage:
  # - Include this module to your ActiveRecord Model
  # - Add `sort_priority` to the model
  #
  # Returns 0, if objects are equal, otherwise by sort priority
  def <=> other
    (sort_priority || 0) <=> (other.sort_priority || 0)
  end
end
