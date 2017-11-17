class AddTimeToBookings < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :start_time, :datetime
    add_column :bookings, :end_time, :datetime
    add_column :bookings, :per_hour, :boolean, default: false

    add_index :bookings, :per_hour
    add_index :bookings, :start_time
    add_index :bookings, :end_time
  end
end
