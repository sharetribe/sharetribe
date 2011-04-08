class SwitchLocationIds < ActiveRecord::Migration
  def self.up
  remove_column :people, :location_id
  remove_column :listings, :origin_loc_id
  remove_column :listings, :destination_loc_id
  add_column :locations, :person_id, :integer
  add_column :locations, :listing_id, :integer
  end

  def self.down
  add_column :people, :location_id
  add_column :listings, :origin_loc_id
  add_column :listings, :destination_loc_id
  remove_column :locations, :person_id
  remove_column :locations, :listing_id
  end
end
