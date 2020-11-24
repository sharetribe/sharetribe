class AddStarterAndListingAuthorUuidsToTransactions < ActiveRecord::Migration

  def up
    # `add_column` with `:binary, limit: 16` uses the VARBINARY type,
    # but we want to use the BINARY type, which is why we use plain
    # SQL here.
    execute "ALTER TABLE transactions ADD starter_uuid BINARY(16) AFTER `starter_id`"
    execute "ALTER TABLE transactions ADD listing_author_uuid BINARY(16) AFTER `listing_author_id`"
    # NOT NULL and UNIQUE constraints are coming in separate
    # migrations once the old data is migrated
  end

  def down
    remove_column :transactions, :starter_uuid
    remove_column :transactions, :listing_author_uuid
  end
end
