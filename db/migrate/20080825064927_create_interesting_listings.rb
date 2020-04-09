class CreateInterestingListings < ActiveRecord::Migration[5.2]
  def self.up
    create_table :interesting_listings do |t|
      t.string :person_id
      t.integer :listing_id

      t.timestamps
    end
  end

  def self.down
    drop_table :interesting_listings
  end
end
