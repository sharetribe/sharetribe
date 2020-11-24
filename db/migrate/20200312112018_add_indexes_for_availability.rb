class AddIndexesForAvailability < ActiveRecord::Migration[5.2]
  def change
    add_index :listing_blocked_dates, [:listing_id, :blocked_at], unique: true
    add_index :bookings, [:transaction_id, :start_on, :end_on, :per_hour],
      name: 'index_bookings_on_transaction_start_on_end_on_per_hour'
    add_index :transactions, [:listing_id, :current_state]
  end
end
