class AddColumnLastModifiedToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :last_modified, :datetime
    Listing.find(:all).each { |listing| listing.update_attribute :last_modified, listing.created_at}
  end

  def self.down
    remove_column :listings, :last_modified
  end
end
