module UUIDUtils

  # This lambda can be used as a Entity transformer.
  #
  # Usage:
  #
  # [:listing_uuid, :uuid, transform_with: UUIDUtils::PARSE_RAW]
  #
  PARSE_RAW = ->(v) {
    case v
    when nil
      nil
    when UUIDTools::UUID
      v
    else
      parse_raw(v)
    end
  }

  # This lambda can be used as a Entity transformer.
  #
  # Usage:
  #
  # [:listing_uuid, :uuid, transform_with: UUIDUtils::RAW]
  #
  RAW = ->(v) {
    case v
    when nil
      nil
    when String
      v
    else
      raw(v)
    end
  }

  V0_UUID = UUIDTools::UUID.parse("00000000-0000-0000-0000-000000000000")

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

  def v0_uuid
    V0_UUID
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
