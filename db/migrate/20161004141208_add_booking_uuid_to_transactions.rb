class AddBookingUuidToTransactions < ActiveRecord::Migration
  def up
    # `add_column` with `:binary, limit: 16` uses the VARBINARY type,
    # but we want to use the BINARY type, which is why we use plain
    # SQL here.
    execute "ALTER TABLE transactions ADD booking_uuid BINARY(16) AFTER `availability`"
  end

  def down
    remove_column :transactions, :booking_uuid
  end
end
