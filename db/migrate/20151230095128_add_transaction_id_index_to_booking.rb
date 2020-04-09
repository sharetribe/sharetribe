class AddTransactionIdIndexToBooking < ActiveRecord::Migration[5.2]
  def change
    add_index "bookings", ["transaction_id"]
  end
end
