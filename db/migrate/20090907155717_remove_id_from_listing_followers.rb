class RemoveIdFromListingFollowers < ActiveRecord::Migration[5.2]
  def self.up
    drop_table :listing_followers
    create_table :listing_followers, :id => false do |t|
      t.string :person_id
      t.integer :listing_id

      t.timestamps
    end
  end

  def self.down
    drop_table :listing_followers
    create_table :listing_followers do |t|
      t.string :person_id
      t.integer :listing_id

      t.timestamps
    end
  end
end
