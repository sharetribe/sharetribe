class PopulatePeopleUuid < ActiveRecord::Migration

  class Person < ApplicationRecord
  end

  def up
    Person.order(:created_at).pluck(:id).each_slice(1000) { |ids|
      selects = ids.map { |id|
        "SELECT '#{id}' AS id, #{create_sql_uuid} AS uuid"
      }

      sql = "UPDATE people orig
               JOIN (
                 #{selects.join("\nUNION ALL\n")}
               ) joined
               ON orig.id = joined.id
               SET orig.uuid = joined.uuid"

      exec_update(sql, "Update people UUIDs", [])
    }
  end

  ## UUIDUtils

  def create_sql_uuid
    "0x#{create_raw.unpack('H*')[0]}"
  end

  def create
    UUIDTools::UUID.timestamp_create
  end

  def create_raw
    raw(create)
  end

  def raw(uuid)
    to_rearranged(uuid.raw)
  end

  def to_rearranged(b)
    high = b[0..3]
    mid = b[4..5]
    low = b[6..7]
    rest = b[8..15]

    [*low, *mid, *high, *rest].join
  end
end
