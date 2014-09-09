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

  def trim(xs)
    xs.drop_while { |x| x.blank? }.reverse.drop_while { |x| x.blank? }.reverse
  end
end
