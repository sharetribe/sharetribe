class AddEndOnExclusiveToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :end_on_exclusive, :date, after: :end_on
  end
end
