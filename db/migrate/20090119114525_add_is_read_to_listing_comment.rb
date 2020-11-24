class AddIsReadToListingComment < ActiveRecord::Migration
  def self.up
    add_column :listing_comments, :is_read, :integer, :default => 0
  end

  def self.down
    remove_column :listing_comments, :is_read
  end
end
