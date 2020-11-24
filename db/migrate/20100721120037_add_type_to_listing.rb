class AddTypeToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :type, :string
  end

  def self.down
    remove_column :listings, :type
  end
end
