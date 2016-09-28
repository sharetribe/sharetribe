module UUIDUtils

  module_function

  def create
    UUIDTools::UUID.timestamp_create
  end

  def create_raw
    raw(create)
  end

  def parse_raw(raw_uuid)
    UUIDTools::UUID.parse_raw(from_rearranged(raw_uuid))
  end

  def raw(uuid)
    to_rearranged(uuid.raw)
  end

  def base64_to_uuid(base64)
    UUIDTools::UUID.parse_raw(Base64.urlsafe_decode64(base64))
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
