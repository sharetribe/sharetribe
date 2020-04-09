class FixLocationAgain < ActiveRecord::Migration[5.2]
  def self.up
  	remove_column :listings, :destionation_loc_id
	add_column :listings, :destination_loc_id, :integer
  end

  def self.down
  	add_column :listings, :destionation_loc_id
	remove_column :listings, :destination_loc_id, :integer
  end
end
