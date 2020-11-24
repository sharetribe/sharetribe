class RemoveEndOnExclusiveColumn < ActiveRecord::Migration
  def change
    remove_column :bookings, :end_on_exclusive, :date, after: :end_on
  end
end
