class AddPrivateToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :private, :boolean, :default => 0
  end

  def self.down
    remove_column :communities, :private
  end
end
