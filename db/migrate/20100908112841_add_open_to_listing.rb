class AddOpenToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :open, :boolean, :default => true
  end

  def self.down
    remove_column :listings, :open
  end
end
