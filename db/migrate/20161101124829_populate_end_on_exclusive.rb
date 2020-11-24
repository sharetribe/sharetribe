class PopulateEndOnExclusive < ActiveRecord::Migration
  def up
    name = "Populate end_on_exclusive for day bookings"
    exec_update([
                  "UPDATE bookings",
                  "LEFT JOIN transactions ON transactions.id = bookings.transaction_id",
                  "SET bookings.end_on_exclusive = ",
                  "CASE transactions.unit_type",
                  "WHEN 'day' THEN ADDDATE(bookings.end_on, 1)",
                  "ELSE bookings.end_on",
                  "END"
                ].join(" "), name, [])
  end

  def down
    name = "Rollback populate end_on_exclusive for day bookings"
    exec_update([
                  "UPDATE bookings",
                  "LEFT JOIN transactions ON transactions.id = bookings.transaction_id",
                  "SET bookings.end_on = ",
                  "CASE transactions.unit_type",
                  "WHEN 'day' THEN SUBDATE(bookings.end_on_exclusive, 1)",
                  "ELSE bookings.end_on_exclusive",
                  "END"
                ].join(" "), name, [])
  end
end
