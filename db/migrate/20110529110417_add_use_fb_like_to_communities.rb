class AddUseFbLikeToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :use_fb_like, :boolean, :default => 0
  end

  def self.down
    remove_column :communities, :use_fb_like
  end
end
