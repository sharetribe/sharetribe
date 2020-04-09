class AddDayUnitToTxsWithBooking < ActiveRecord::Migration[5.2]
# We have some rows in `transactions` table that do not have unit_type
  #
  def up
    name = "Add day unit type to transaction with booking and without unit type"
    exec_update([
                  "UPDATE transactions",
                  "INNER JOIN bookings ON bookings.transaction_id = transactions.id",
                  "SET transactions.unit_type = 'day'",
                  "WHERE transactions.unit_type IS NULL"
                ].join(" "), name, [])
  end
end
