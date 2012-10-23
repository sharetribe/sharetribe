class AddCommunityIdToCachedRessiEvents < ActiveRecord::Migration
  def self.up
    add_column :cached_ressi_events, :community_id, :integer
  end

  def self.down
    remove_column :cached_ressi_events, :community_id
  end
end
