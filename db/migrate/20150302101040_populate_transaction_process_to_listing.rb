class PopulateTransactionProcessToListing < ActiveRecord::Migration
  def up
    execute("
      UPDATE listings
      LEFT JOIN listing_shapes ON (listings.listing_shape_id = listing_shapes.id)
      LEFT JOIN transaction_processes ON (transaction_processes.listing_shape_id = listing_shapes.id)

      SET listings.transaction_process_id = transaction_processes.id
    ")
  end

  def down
    execute("UPDATE listings SET transaction_process_id = NULL")
  end
end
