
module ListingShapeHelper


  PREDEFINED_UNIT_TYPES = ['unit', 'hour', 'day', 'night', 'week', 'month']

  module_function

  # deprecated
  #
  # This method is deprecated, but it's still in use in Atom API
  def shape_direction_map(shapes, processes)
    ArrayUtils.inner_join(shapes, processes) { |shape, process|
      shape[:transaction_process_id] == process[:id]
    }.map { |(shape, process)|
      [shape[:id], process_to_direction(process)]
    }.to_h
  end

  def process_to_direction(process)
    process[:author_is_seller] ? "offer" : "request"
  end

  def predefined_unit_types
    PREDEFINED_UNIT_TYPES
  end

end
