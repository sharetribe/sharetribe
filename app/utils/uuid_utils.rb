module UUIDUtils

  module_function

  def create_raw
    raw(UUIDTools::UUID.timestamp_create)
  end

  def parse_raw(raw_uuid)
    UUIDTools::UUID.parse_raw(from_rearranged(raw_uuid))
  end

  def raw(uuid)
    to_rearranged(uuid.raw)
  end

  # private

  def to_rearranged(b)
    high = b[0..3]
    mid = b[4..5]
    low = b[6..7]
    rest = b[8..15]

    [*low, *mid, *high, *rest].join
  end

  def from_rearranged(b)
    low = b[0..1]
    mid = b[2..3]
    high = b[4..7]
    rest = b[8..15]

    [*high, *mid, *low, *rest].join
  end

end
