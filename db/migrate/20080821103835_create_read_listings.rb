class CreateReadListings < ActiveRecord::Migration[5.2]
  def self.up
    create_table :read_listings do |t|
      t.string :person_id
      t.integer :listing_id

      t.timestamps
    end
  end

  def self.down
    drop_table :read_listings
  end
end
