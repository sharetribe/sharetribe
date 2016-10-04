class RearrangeListingUuidBytesProperly < ActiveRecord::Migration
  def up
    Listing.pluck(:id).each_slice(1000) { |ids|
      uuids = ids.map { UUIDUtils.create_raw }
      ActiveRecord::Base.transaction do
        selects = ids.zip(uuids).map { |id, uuid|
          "SELECT #{id} AS listing_id, 0x#{uuid.unpack('H*')[0]} as listing_uuid"
        }
        sql = "UPDATE listings l
               JOIN (
                 #{selects.join("\nUNION ALL\n")}
               ) u
               ON l.id = u.listing_id
               SET l.uuid = u.listing_uuid"
        exec_update(sql, "Update listing UUIDs", [])
      end
    }
  end
end
