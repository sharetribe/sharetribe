class CreateListingBlockedDates < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_blocked_dates do |t|
      t.references :listing
      t.date :blocked_at

      t.timestamps
    end
  end
end
