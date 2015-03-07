class AddTransactionProcessToListing < ActiveRecord::Migration
  def change
    add_column :listings, :transaction_process_id, :int, after: :listing_shape_id
  end
end
