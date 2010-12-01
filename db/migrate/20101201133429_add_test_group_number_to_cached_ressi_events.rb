class AddTestGroupNumberToCachedRessiEvents < ActiveRecord::Migration
  def self.up
    add_column :cached_ressi_events, :test_group_number, :integer
  end

  def self.down
    remove_column :cached_ressi_events, :test_group_number
  end
end
