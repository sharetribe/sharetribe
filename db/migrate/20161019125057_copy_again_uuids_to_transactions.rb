class CopyAgainUuidsToTransactions < ActiveRecord::Migration
  def up
    execute "UPDATE transactions, listings SET transactions.listing_uuid = listings.uuid WHERE transactions.listing_id = listings.id"
    execute "UPDATE transactions, communities SET transactions.community_uuid = communities.uuid WHERE transactions.community_id = communities.id"
  end

  def down
    # No-op. We lost the previous data so there's nothing we can do.
  end
end
