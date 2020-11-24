class AddCommentsCountToListings < ActiveRecord::Migration

  def self.up
    add_column :listings, :comments_count, :integer, :default => 0
    Listing.reset_column_information
    Listing.select(:id).find_each do |l|
      Listing.reset_counters l.id, :comments
    end
  end

  def self.down
    remove_column :listings, :comments_count
  end

end
