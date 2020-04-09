class AddColumnLastModifiedToListing < ActiveRecord::Migration[5.2]
def self.up
    add_column :listings, :last_modified, :datetime
  end

  def self.down
    remove_column :listings, :last_modified
  end
end
