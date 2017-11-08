class CreateListingWorkingTimeSlots < ActiveRecord::Migration[5.1]
  def change
    create_table :listing_working_time_slots do |t|
      t.integer :listing_id
      t.integer :week_day
      t.string :from
      t.string :till

      t.timestamps
    end
    add_index :listing_working_time_slots, :listing_id
  end
end
