class FixLocationModelAssociations < ActiveRecord::Migration
  def self.up
	  add_column :people, :location_id, :integer
	  add_column :listings, :origin_loc_id, :integer
	  add_column :listings, :destionation_loc_id, :integer
  end

  def self.down
	  remove_column :people, :location_id
	  remove_column :listings, :origin_loc_id
	  remove_column :listings, :destionation_loc_id
  end
end
