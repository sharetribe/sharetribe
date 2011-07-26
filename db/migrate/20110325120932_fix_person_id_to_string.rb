class FixPersonIdToString < ActiveRecord::Migration
  def self.up
  	remove_column :locations, :person_id
  	add_column :locations, :person_id, :string

  end

  def self.down
  	remove_column :locations, :person_id
  	add_column :locations, :person_id, :integer
  end
end
