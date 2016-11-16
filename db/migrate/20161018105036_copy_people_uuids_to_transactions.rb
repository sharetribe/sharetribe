class CopyPeopleUuidsToTransactions < ActiveRecord::Migration
  def up
    execute "UPDATE transactions, people SET transactions.starter_uuid = people.uuid WHERE transactions.starter_id = people.id"
    execute "UPDATE transactions, people SET transactions.listing_author_uuid = people.uuid WHERE transactions.listing_author_id = people.id"
  end

  def down
    execute "UPDATE transactions SET starter_uuid = NULL, listing_author_uuid = NULL"
  end
end
