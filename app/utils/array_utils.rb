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

  def inner_join(a, b, &block)
    a.reduce([]) { |joins, a_elem|
      bs_found = b.select { |b_elem| block ? block.call(a_elem, b_elem) : a_elem == b_elem }
      if bs_found.empty?
        joins
      else
        joins.concat([[a_elem].concat(bs_found)])
      end
    }
  end

  # ArrayUtils.diff_by_key(
  # [{id: 1, value: :a}, {id: 2, value: :b}],
  # [{id: 2, value: :d}, {id: 3, value: :c}])
  # =>
  # [
  #   {action: :removed, value: {id: 1, value: :a}},
  #   {action: :changed, value: {id: 2, value: :d}},
  #   {action: :added, value {id: 3, value: :d}}
  # ]
  #
  # Element without key is always considered as new addition
  #
  def diff_by_key(old_array, new_array, key)
    operations = []
    new_without_key, new_with_key = new_array.partition { |new| new[key].nil? }
    old_elems = old_array.sort_by { |old| old[key] }
    new_elems = new_with_key.sort_by { |new| new[key] }

    # Traverse sorted old and new arrays
    until old_elems.empty? || new_elems.empty?
      old = old_elems.first
      new = new_elems.first

      case old[key] <=> new[key]
      when -1
        # remove
        operations << {action: :removed, value: old}
        old_elems.shift
      when 0
        if old == new
          # no change
        else
          # update
          operations << {action: :changed, value: new}
        end
        old_elems.shift
        new_elems.shift
      when 1
        # add
        operations << {action: :added, value: new}
        new_elems.shift
      end
    end

    # See if there's still left something to process in old or new array
    old_elems.each { |old| operations << {action: :removed, value: old}}
    new_elems.each { |new| operations << {action: :added, value: new}}

    # Element without key is always considered as new addition
    new_without_key.each { |new| operations << {action: :added, value: new}}

    operations
  end
end
