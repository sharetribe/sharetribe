class CopyUuidsToTransactions < ActiveRecord::Migration
  def up
    execute "UPDATE transactions, listings SET transactions.listing_uuid = listings.uuid WHERE transactions.listing_id = listings.id"
    execute "UPDATE transactions, communities SET transactions.community_uuid = communities.uuid WHERE transactions.community_id = communities.id"
  end

  def down
    execute "UPDATE transactions SET listing_uuid = NULL, community_uuid = NULL"
  end
end
