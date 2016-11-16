class PopulateExclusiveEndWhereUnitTypeIsNull < ActiveRecord::Migration
  def up
    name = "Populate end_on_exclusive for bookings where unit type is NULL"
    exec_update([
                  "UPDATE bookings",
                  "INNER JOIN transactions ON transactions.id = bookings.transaction_id",
                  "SET bookings.end_on_exclusive = ADDDATE(bookings.end_on, 1)",
                  "WHERE transactions.unit_type IS NULL"
                ].join(" "), name, [])
  end
end
