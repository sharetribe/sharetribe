class RemoveLocationOk < ActiveRecord::Migration
  def self.up
    remove_column :locations, :location_ok
  end

  def self.down
    add_column :locations, :location_ok, :boolean
  end
end
