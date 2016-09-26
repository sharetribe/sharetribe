class RearrangeCommunityUuidBytes < ActiveRecord::Migration
  def change
    Community.all.each { |c|
      c.uuid = UUIDUtils.create_raw
      c.save()
    }
  end
end
