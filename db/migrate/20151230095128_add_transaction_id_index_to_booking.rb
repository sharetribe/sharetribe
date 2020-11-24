class AddTransactionIdIndexToBooking < ActiveRecord::Migration
  def change
    add_index "bookings", ["transaction_id"]
  end
end
